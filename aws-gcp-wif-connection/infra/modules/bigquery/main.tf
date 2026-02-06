resource "google_bigquery_dataset" "default" {
  project                     = var.project_id
  dataset_id                  = var.dataset_id
  friendly_name               = var.dataset_name
  description                 = var.dataset_description
  location                    = var.location
  default_table_expiration_ms = 3600000

  labels = var.labels
}

resource "google_bigquery_table" "default" {
  project             = var.project_id
  dataset_id          = google_bigquery_dataset.default.dataset_id
  table_id            = var.table_id
  deletion_protection = false


  time_partitioning {
    type = "DAY"
  }

  labels = var.labels

  schema = local.table_schema
}
