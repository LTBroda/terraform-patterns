variable "gcp_project_id" {
  description = "GCP project ID where WIF resources will be created"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID that will be allowed to authenticate"
  type        = string
}

variable "pool_id" {
  description = "ID for the Workload Identity Pool"
  type        = string
}

variable "provider_id" {
  description = "ID for the Workload Identity Provider"
  type        = string
}

variable "service_account_id" {
  description = "ID for the GCP service account"
  type        = string
}

variable "lambda_role_name" {
  description = "Name of the AWS Lambda execution role"
  type        = string
}

variable "bigquery_dataset_id" {
  description = "BigQuery dataset ID to grant access to"
  type        = string
}
