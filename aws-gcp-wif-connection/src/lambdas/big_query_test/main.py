import os
import json
from typing import Any, Dict
from google.auth import aws
from google.cloud import bigquery
from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext

logger = Logger()
_bigquery_client = None


def get_bigquery_client() -> bigquery.Client:
    """Create BigQuery client using WIF."""
    global _bigquery_client

    if _bigquery_client is not None:
        return _bigquery_client

    project_id = os.environ['GCP_PROJECT_ID']
    provider_name = os.environ['GCP_WORKLOAD_PROVIDER']
    service_account = os.environ['GCP_SERVICE_ACCOUNT']

    # Construct audience from provider resource name
    audience = f"//iam.googleapis.com/{provider_name}"

    logger.info("Authenticating to GCP via WIF", extra={
        "project": project_id,
        "service_account": service_account
    })

    # Configure credential source for AWS Lambda environment
    credential_source = {
        "environment_id": "aws1",
        "region_url": "http://169.254.169.254/latest/meta-data/placement/availability-zone",
        "url": "http://169.254.169.254/latest/meta-data/iam/security-credentials",
        "regional_cred_verification_url": "https://sts.{region}.amazonaws.com?Action=GetCallerIdentity&Version=2011-06-15"
    }

    # Create credentials using AWS execution role
    credentials = aws.Credentials(
        audience=audience,
        subject_token_type="urn:ietf:params:aws:token-type:aws4_request",
        credential_source=credential_source,
        service_account_impersonation_url=f"https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/{service_account}:generateAccessToken",
        scopes=["https://www.googleapis.com/auth/cloud-platform"]
    )

    _bigquery_client = bigquery.Client(
        project=project_id,
        credentials=credentials
    )

    logger.info("BigQuery client initialized")
    return _bigquery_client


@logger.inject_lambda_context
def main(event: Dict[str, Any], context: LambdaContext) -> Dict[str, Any]:
    """Test BigQuery connectivity by querying table records."""
    try:
        client = get_bigquery_client()

        # Get table information from environment
        dataset_id = os.environ['BIGQUERY_DATASET']
        table_id = os.environ['BIGQUERY_TABLE']
        project_id = os.environ['GCP_PROJECT_ID']

        # Query to select 10 records from the table
        query = f"""
            SELECT *
            FROM `{project_id}.{dataset_id}.{table_id}`
            LIMIT 10
        """
        logger.info(f"Executing query on {project_id}.{dataset_id}.{table_id}")

        query_job = client.query(query)
        results = query_job.result()

        # Collect results
        rows = []
        for row in results:
            rows.append(dict(row.items()))

        logger.info(f"Query returned {len(rows)} rows")

        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "BigQuery WIF connection successful",
                "row_count": len(rows),
                "rows": rows,
                "method": "Workload Identity Federation"
            })
        }

    except Exception as e:
        logger.exception("Error querying BigQuery")
        return {
            "statusCode": 500,
            "body": json.dumps({
                "error": str(e),
                "error_type": type(e).__name__
            })
        }
