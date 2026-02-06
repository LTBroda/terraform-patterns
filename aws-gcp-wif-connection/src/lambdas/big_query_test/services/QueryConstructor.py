import os

from services.exceptions import MissingEnvironmentVariableError


class QueryConstructor:
    def __init__(self) -> None:
        try:
            self.dataset_id = os.environ["BIGQUERY_DATASET"]
            self.table_id = os.environ["BIGQUERY_TABLE"]
            self.project_id = os.environ["GCP_PROJECT_ID"]
        except KeyError as e:
            missing_var = e.args[0]
            msg = (
                f"Missing required environment variable: {missing_var}. "
                f"Required variables: GCP_PROJECT_ID, GCP_WORKLOAD_PROVIDER, GCP_SERVICE_ACCOUNT"
            )
            raise MissingEnvironmentVariableError(msg) from e

    def _get_table_name(self) -> str:
        return f"{self.project_id}.{self.dataset_id}.{self.table_id}"

    def get_records_query(self) -> str:
        return f"""
            SELECT *
            FROM `{self._get_table_name()}`
            LIMIT 10
        """
