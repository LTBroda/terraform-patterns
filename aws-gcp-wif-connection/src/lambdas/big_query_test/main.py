import json
from typing import Any

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext
from services.BigQueryProvider import BigQueryProvider
from services.QueryConstructor import QueryConstructor

logger = Logger()


@logger.inject_lambda_context
def main(event: dict, context: LambdaContext) -> dict[str, Any]:
    """Test BigQuery connectivity by querying table records."""

    try:
        client = BigQueryProvider().get_client()
        query_constructor = QueryConstructor()

        query_job = client.query(query_constructor.get_records_query())
        results = query_job.result()

        rows = []
        for row in results:
            rows.append(dict(row.items()))

        logger.info(f"Query returned {len(rows)} rows")

        return {
            "statusCode": 200,
            "body": json.dumps(
                {
                    "message": "BigQuery WIF connection successful",
                    "rows": rows,
                }
            ),
        }

    except Exception as e:
        logger.exception("Error querying BigQuery")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e), "error_type": type(e).__name__}),
        }
