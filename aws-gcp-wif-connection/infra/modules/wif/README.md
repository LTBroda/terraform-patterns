# Workload Identity Federation (WIF) Module

This Terraform module sets up Workload Identity Federation to enable AWS Lambda functions to authenticate with Google Cloud Platform (GCP) and access BigQuery without using service account keys.

## Overview

Workload Identity Federation provides a secure, keyless authentication mechanism that allows AWS workloads to impersonate GCP service accounts. This eliminates the need to manage and rotate service account keys, reducing security risks and operational overhead.

## Architecture

The module creates the following resources:

1. **Workload Identity Pool**: A container for managing external identity providers
2. **AWS Provider**: Configures AWS as a trusted identity provider
3. **GCP Service Account**: Service account that AWS Lambda will impersonate
4. **IAM Bindings**: Grants necessary BigQuery permissions and workload identity bindings

### Authentication Flow

```
AWS Lambda (with IAM role)
    ↓ (assumes role and gets AWS credentials)
AWS STS Token
    ↓ (exchanges via WIF)
GCP Access Token (impersonating service account)
    ↓ (authenticated access)
BigQuery
```

## Features

- Keyless authentication from AWS to GCP
- Automatic API enablement (IAM, IAM Credentials)
- Pre-configured BigQuery permissions (user, job user, data viewer)
- Attribute mapping for AWS role-based access control
- Dataset-level access control

## Prerequisites

- GCP project with billing enabled
- AWS account with Lambda functions deployed
- Terraform >= 1.0
- Required permissions:
  - GCP: `roles/resourcemanager.projectIamAdmin`, `roles/iam.serviceAccountAdmin`
  - AWS: Access to Lambda execution role details

## Usage

```hcl
module "wif" {
  source = "./modules/wif"

  gcp_project_id      = "my-gcp-project"
  aws_account_id      = "123456789012"
  pool_id             = "aws-lambda-pool"
  provider_id         = "aws-lambda-provider"
  service_account_id  = "lambda-bigquery-sa"
  lambda_role_name    = "my-lambda-execution-role"
  bigquery_dataset_id = "my_dataset"
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| `gcp_project_id` | GCP project ID where WIF resources will be created | `string` | Yes |
| `aws_account_id` | AWS account ID that will be allowed to authenticate | `string` | Yes |
| `pool_id` | ID for the Workload Identity Pool | `string` | Yes |
| `provider_id` | ID for the Workload Identity Provider | `string` | Yes |
| `service_account_id` | ID for the GCP service account | `string` | Yes |
| `lambda_role_name` | Name of the AWS Lambda execution role | `string` | Yes |
| `bigquery_dataset_id` | BigQuery dataset ID to grant access to | `string` | Yes |

## Outputs

| Name | Description | Usage |
|------|-------------|-------|
| `workload_pool_id` | ID of the Workload Identity Pool | Reference in other modules |
| `workload_provider_id` | ID of the Workload Identity Provider | Reference in other modules |
| `workload_provider_name` | Full resource name of the provider | Use as `audience` in token exchange |
| `service_account_email` | Email of the GCP service account | Use in application code for impersonation |
| `service_account_name` | Full resource name of the service account | Reference in IAM bindings |

## Permissions Granted

The module automatically grants the following permissions to the service account:

### Project-level:
- `roles/bigquery.user` - Create and run queries
- `roles/bigquery.jobUser` - Run BigQuery jobs

### Dataset-level:
- `roles/bigquery.dataViewer` - Read data from tables

## Example: Complete Setup

```hcl
# Configure providers
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "aws" {
  region = var.aws_region
}

# Create BigQuery dataset
module "bigquery" {
  source = "./modules/bigquery"

  project_id = var.gcp_project_id
  dataset_id = "analytics"
  # ... other variables
}

# Setup WIF
module "wif" {
  source = "./modules/wif"

  gcp_project_id      = var.gcp_project_id
  aws_account_id      = var.aws_account_id
  pool_id             = "aws-lambda-pool"
  provider_id         = "aws-lambda-provider"
  service_account_id  = "lambda-bigquery-sa"
  lambda_role_name    = "lambda-execution-role"
  bigquery_dataset_id = module.bigquery.dataset_id
}

# Use outputs in Lambda configuration
output "audience" {
  value = module.wif.workload_provider_name
}

output "service_account" {
  value = module.wif.service_account_email
}
```

## Using from AWS Lambda

After deploying this module, configure your Lambda function to use the credentials:

### Python Example

```python
import google.auth
from google.auth import aws
from google.cloud import bigquery

# Configure WIF
credentials = aws.Credentials(
    audience='//iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID/providers/PROVIDER_ID',
    subject_token_type='urn:ietf:params:aws:token-type:aws4_request',
    token_url='https://sts.googleapis.com/v1/token',
    service_account_impersonation_url=f'https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/SERVICE_ACCOUNT_EMAIL:generateAccessToken'
)

# Use credentials with BigQuery client
client = bigquery.Client(credentials=credentials, project='my-gcp-project')
```

### Environment Variables in Lambda

Set these environment variables in your Lambda function:

```bash
GCP_WORKLOAD_PROVIDER_NAME=//iam.googleapis.com/projects/.../providers/aws-lambda-provider
GCP_SERVICE_ACCOUNT_EMAIL=lambda-bigquery-sa@PROJECT_ID.iam.gserviceaccount.com
GCP_PROJECT_ID=my-gcp-project
```

## Security Considerations

1. **Least Privilege**: The module grants only necessary BigQuery permissions
2. **AWS Role Binding**: Only the specified Lambda role can authenticate
3. **Attribute Mapping**: AWS role ARN is mapped to custom attributes for fine-grained access control
4. **No Key Management**: Eliminates risks associated with service account key distribution

## Troubleshooting

### Common Issues

**Error: "Failed to generate access token"**
- Verify the Lambda execution role name matches `lambda_role_name`
- Check that the role has been assumed by the Lambda function
- Ensure AWS account ID is correct

**Error: "Permission denied on BigQuery"**
- Verify the dataset ID is correct
- Check that additional table/row-level permissions aren't required
- Ensure the service account has proper IAM bindings

**Error: "Workload Identity Pool not found"**
- Wait a few minutes for API enablement to propagate
- Check that `iamcredentials.googleapis.com` is enabled

## Resources Created

This module creates the following GCP resources:

- `google_project_service.iamcredentials` - Enables IAM Credentials API
- `google_project_service.iam` - Enables IAM API
- `google_iam_workload_identity_pool.aws_pool` - Workload Identity Pool
- `google_iam_workload_identity_pool_provider.aws_provider` - AWS Provider
- `google_service_account.lambda_bigquery` - Service Account
- `google_project_iam_member.bigquery_user` - BigQuery User role binding
- `google_project_iam_member.bigquery_job_user` - BigQuery Job User role binding
- `google_bigquery_dataset_iam_member.dataset_viewer` - Dataset viewer role binding
- `google_service_account_iam_member.workload_identity_binding` - Workload Identity binding

## References

- [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Configure workload identity federation with AWS](https://cloud.google.com/iam/docs/workload-identity-federation-with-other-clouds#aws)
- [BigQuery IAM Roles](https://cloud.google.com/bigquery/docs/access-control)

## License

This module is part of the aws-gcp-wif-connection project.
