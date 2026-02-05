output "dataset_id" {
  description = "The ID of the BigQuery dataset"
  value       = google_bigquery_dataset.default.dataset_id
}

output "dataset_project" {
  description = "The project ID of the BigQuery dataset"
  value       = google_bigquery_dataset.default.project
}

output "table_id" {
  description = "The ID of the BigQuery table"
  value       = google_bigquery_table.default.table_id
}

output "table_full_id" {
  description = "The fully qualified table ID (project:dataset.table)"
  value       = "${var.project_id}:${google_bigquery_dataset.default.dataset_id}.${google_bigquery_table.default.table_id}"
}
