import os
from typing import ClassVar

from google.auth import aws
from google.cloud import bigquery
from services.exceptions import BigQueryProviderError, MissingEnvironmentVariableError

_bigquery_client: bigquery.Client | None = None


class BigQueryProvider:
    """Provider for BigQuery client with AWS Workload Identity Federation authentication."""

    # Uses IMDSv1 endpoint for retrieving AWS instance metadata
    CREDENTIAL_SOURCE: ClassVar[dict[str, str]] = {
        "environment_id": "aws1",
        "region_url": "http://169.254.169.254/latest/meta-data/placement/availability-zone",
        "url": "http://169.254.169.254/latest/meta-data/iam/security-credentials",
        "regional_cred_verification_url": "https://sts.{region}.amazonaws.com?Action=GetCallerIdentity&Version=2011-06-15",
    }

    def __init__(self) -> None:
        try:
            self.project_id = os.environ["GCP_PROJECT_ID"]
            self.provider_name = os.environ["GCP_WORKLOAD_PROVIDER"]
            self.service_account = os.environ["GCP_SERVICE_ACCOUNT"]
        except KeyError as e:
            missing_var = e.args[0]
            msg = (
                f"Missing required environment variable: {missing_var}. "
                f"Required variables: GCP_PROJECT_ID, GCP_WORKLOAD_PROVIDER, GCP_SERVICE_ACCOUNT"
            )
            raise MissingEnvironmentVariableError(msg) from e

    def _get_audience(self) -> str:
        """Get the audience URL for the workload identity provider."""
        return f"//iam.googleapis.com/{self.provider_name}"

    def _get_aws_credentials(self) -> aws.Credentials:
        """Create AWS credentials object for GCP authentication."""
        try:
            return aws.Credentials(
                audience=self._get_audience(),
                subject_token_type="urn:ietf:params:aws:token-type:aws4_request",
                credential_source=self.CREDENTIAL_SOURCE,
                service_account_impersonation_url=(
                    f"https://iamcredentials.googleapis.com/v1/projects/-/"
                    f"serviceAccounts/{self.service_account}:generateAccessToken"
                ),
                scopes=["https://www.googleapis.com/auth/cloud-platform"],
            )
        except Exception as e:
            msg = f"Failed to create AWS credentials: {e}"
            raise BigQueryProviderError(msg) from e

    def get_client(self) -> bigquery.Client:
        """Get or create a BigQuery client instance.

        Returns a cached client if available, otherwise creates a new one.
        """
        global _bigquery_client

        if _bigquery_client is not None:
            return _bigquery_client

        try:
            credentials = self._get_aws_credentials()
            _bigquery_client = bigquery.Client(project=self.project_id, credentials=credentials)
            return _bigquery_client
        except Exception as e:
            msg = f"Failed to create BigQuery client: {e}"
            raise BigQueryProviderError(msg) from e
