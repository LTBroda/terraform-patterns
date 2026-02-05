variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "dataset_id" {
  description = "BigQuery dataset ID"
  type        = string
  default     = "test_dataset"
}

variable "dataset_name" {
  description = "Friendly name for the dataset"
  type        = string
  default     = "Test Dataset"
}

variable "dataset_description" {
  description = "Description for the dataset"
  type        = string
  default     = "Dataset for testing BigQuery integration"
}

variable "location" {
  description = "Location/region for the dataset (e.g., US, EU)"
  type        = string
  default     = "EU"
}

variable "table_id" {
  description = "BigQuery table ID"
  type        = string
  default     = "test_table"
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default = {
    env = "dev"
  }
}
