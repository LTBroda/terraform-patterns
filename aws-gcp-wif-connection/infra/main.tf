data "aws_caller_identity" "current" {}

module "bigquery_test" {
  source = "./modules/bigquery"

  project_id = var.gcp_project_id
  dataset_id = "test_dataset"
  table_id   = "test_table"
  location   = var.gcp_location

  labels = {
    environment = var.environment
    project     = var.project_name
  }
}

module "gcp_auth_layer" {
  source = "./modules/lambda_layer"

  layer_name        = "gcp-auth-layer"
  description       = "Google Cloud auth libraries for WIF"
  python_version    = "3.13"
  requirements_file = "${path.module}/../src/lambdas/big_query_test/requirements.txt"
}

module "wif" {
  source = "./modules/wif"

  gcp_project_id = var.gcp_project_id
  aws_account_id = data.aws_caller_identity.current.account_id

  pool_id             = "aws-lambda-pool"
  provider_id         = "aws-lambda-provider"
  service_account_id  = "lambda-bigquery-sa"
  lambda_role_name    = "big-query-test-role" # Must match Lambda function_name-role pattern
  bigquery_dataset_id = module.bigquery_test.dataset_id
}

module "big_query_test_lambda" {
  source = "./modules/lambda"

  function_name  = "big-query-test"
  description    = "Lambda function for testing BigQuery integration"
  handler        = "main.main"
  python_version = "python3.13"
  source_path    = "${path.module}/../src/lambdas/big_query_test"
  timeout        = 30
  memory_size    = 256

  log_retention_days = 1

  layer_arns = [module.gcp_auth_layer.layer_arn]

  environment_variables = {
    GCP_PROJECT_ID        = var.gcp_project_id
    GCP_WORKLOAD_PROVIDER = module.wif.workload_provider_name
    GCP_SERVICE_ACCOUNT   = module.wif.service_account_email
    BIGQUERY_DATASET      = module.bigquery_test.dataset_id
    BIGQUERY_TABLE        = module.bigquery_test.table_id
  }

  tags = {
    Environment = "dev"
    Project     = var.project_name
  }
}
