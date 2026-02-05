provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "aws-gcp-wif-connection"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}
