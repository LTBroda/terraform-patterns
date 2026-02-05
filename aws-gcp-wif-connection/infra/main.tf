# Main infrastructure configuration
# Add your AWS and GCP resources here

# Lambda function for BigQuery testing
module "big_query_test_lambda" {
  source = "./modules/lambda"

  function_name    = "big-query-test"
  description      = "Lambda function for testing BigQuery integration"
  handler          = "main.main"
  python_version   = "python3.13"
  source_path      = "${path.module}/../src/lambdas/big_query_test"
  timeout          = 30
  memory_size      = 256

  log_retention_days = 1

  tags = {
    Environment = "dev"
    Project     = "aws-gcp-wif"
  }
}
