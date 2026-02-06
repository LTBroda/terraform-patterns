resource "google_service_account" "lambda_bigquery" {
  account_id   = var.service_account_id
  display_name = "Lambda BigQuery Service Account"
  description  = "Service account for AWS Lambda to access BigQuery via WIF"
}
