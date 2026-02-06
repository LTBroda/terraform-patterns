resource "google_project_service" "iamcredentials" {
  project            = var.gcp_project_id
  service            = "iamcredentials.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  project            = var.gcp_project_id
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_iam_workload_identity_pool" "aws_pool" {
  workload_identity_pool_id = var.pool_id
  display_name              = "AWS Lambda WIF Pool"
  description               = "Workload Identity Pool for AWS Lambda to access GCP resources"
  disabled                  = false

  depends_on = [
    google_project_service.iamcredentials,
    google_project_service.iam
  ]
}
