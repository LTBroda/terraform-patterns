# Enable required GCP APIs
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

resource "google_iam_workload_identity_pool_provider" "aws_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.aws_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "AWS Lambda Provider"
  description                        = "AWS provider for Lambda function authentication"

  attribute_mapping = {
    "google.subject"     = "assertion.arn"
    "attribute.aws_role" = "assertion.arn.extract('assumed-role/{role}/')"
  }

  aws {
    account_id = var.aws_account_id
  }
}

resource "google_service_account" "lambda_bigquery" {
  account_id   = var.service_account_id
  display_name = "Lambda BigQuery Service Account"
  description  = "Service account for AWS Lambda to access BigQuery via WIF"
}

resource "google_project_iam_member" "bigquery_user" {
  project = var.gcp_project_id
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.lambda_bigquery.email}"
}

resource "google_project_iam_member" "bigquery_job_user" {
  project = var.gcp_project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.lambda_bigquery.email}"
}

# Grant dataset-level access
resource "google_bigquery_dataset_iam_member" "dataset_viewer" {
  project    = var.gcp_project_id
  dataset_id = var.bigquery_dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${google_service_account.lambda_bigquery.email}"
}

resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.lambda_bigquery.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.aws_pool.name}/attribute.aws_role/${var.lambda_role_name}"
}
