output "workload_pool_id" {
  description = "ID of the Workload Identity Pool"
  value       = google_iam_workload_identity_pool.aws_pool.workload_identity_pool_id
}

output "workload_provider_id" {
  description = "ID of the Workload Identity Provider"
  value       = google_iam_workload_identity_pool_provider.aws_provider.workload_identity_pool_provider_id
}

output "workload_provider_name" {
  description = "Full resource name of the Workload Identity Provider (for audience)"
  value       = google_iam_workload_identity_pool_provider.aws_provider.name
}

output "service_account_email" {
  description = "Email of the GCP service account"
  value       = google_service_account.lambda_bigquery.email
}

output "service_account_name" {
  description = "Full resource name of the GCP service account"
  value       = google_service_account.lambda_bigquery.name
}
