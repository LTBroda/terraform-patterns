# BigQuery Dataset
resource "google_bigquery_dataset" "default" {
  project                     = var.project_id
  dataset_id                  = var.dataset_id
  friendly_name               = var.dataset_name
  description                 = var.dataset_description
  location                    = var.location
  default_table_expiration_ms = 3600000

  labels = var.labels
}

# BigQuery Table
resource "google_bigquery_table" "default" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = var.table_id

  time_partitioning {
    type = "DAY"
  }

  labels = var.labels

  schema = <<EOF
[
  {
    "name": "id",
    "type": "INTEGER",
    "mode": "NULLABLE",
    "description": "Record ID"
  },
  {
    "name": "name",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Name field"
  },
  {
    "name": "created_at",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "Creation timestamp"
  }
]
EOF
}
