# AWS Lambda Terraform Module

Universal AWS Lambda module for deploying Python-based Lambda functions.

## Features

- Automatic source code archiving
- Configurable Python runtime version
- CloudWatch Logs with configurable retention
- IAM role and policy management
- Support for Lambda layers
- Environment variables support
- Additional IAM policy statements support

## Usage

```hcl
module "my_lambda" {
  source = "./modules/lambda"

  function_name  = "my-lambda-function"
  description    = "My Lambda function"
  handler        = "index.handler"
  python_version = "python3.11"
  source_path    = "${path.module}/../lambda/my-function"

  timeout     = 60
  memory_size = 256

  environment_variables = {
    ENV = "production"
    LOG_LEVEL = "INFO"
  }

  layer_arns = [
    "arn:aws:lambda:us-east-1:123456789012:layer:my-layer:1"
  ]

  log_retention_days = 14

  iam_policy_statements = [
    {
      effect    = "Allow"
      actions   = ["s3:GetObject"]
      resources = ["arn:aws:s3:::my-bucket/*"]
    }
  ]

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| function_name | Name of the Lambda function | string | - | yes |
| handler | Lambda function handler | string | - | yes |
| source_path | Path to Lambda source code directory | string | - | yes |
| python_version | Python runtime version | string | python3.11 | no |
| timeout | Function timeout in seconds | number | 30 | no |
| memory_size | Function memory in MB | number | 128 | no |
| environment_variables | Environment variables map | map(string) | {} | no |
| layer_arns | List of Lambda Layer ARNs | list(string) | [] | no |
| log_retention_days | CloudWatch log retention | number | 7 | no |
| iam_policy_statements | Additional IAM policy statements | list(object) | [] | no |
| tags | Resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| function_arn | ARN of the Lambda function |
| function_name | Name of the Lambda function |
| invoke_arn | Invoke ARN of the Lambda function |
| role_arn | ARN of the Lambda execution role |
| role_name | Name of the Lambda execution role |
| log_group_name | Name of the CloudWatch log group |
