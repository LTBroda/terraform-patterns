locals {
  table_schema = jsonencode([
    {
      name        = "id"
      type        = "INTEGER"
      mode        = "NULLABLE"
      description = "Record ID"
    },
    {
      name        = "name"
      type        = "STRING"
      mode        = "NULLABLE"
      description = "Name field"
    },
    {
      name        = "created_at"
      type        = "TIMESTAMP"
      mode        = "NULLABLE"
      description = "Creation timestamp"
    }
  ])
}
