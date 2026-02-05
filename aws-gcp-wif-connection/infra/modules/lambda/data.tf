# Archive the Lambda function source code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_path
  output_path = "${path.module}/.terraform/tmp/${var.function_name}.zip"
}
