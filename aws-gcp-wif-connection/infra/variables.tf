variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "gcp_region" {
  description = "GCP region where resources will be created"
  type        = string
  default     = "us-central1"
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "wif-test"
}

variable "gcp_location" {
  description = "Selected GCP location"
  type        = string
  default     = "US"
}
