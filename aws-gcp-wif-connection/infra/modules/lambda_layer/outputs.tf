output "layer_arn" {
  description = "ARN of the Lambda layer version"
  value       = aws_lambda_layer_version.this.arn
}

output "layer_version" {
  description = "Version number of the Lambda layer"
  value       = aws_lambda_layer_version.this.version
}

output "layer_name" {
  description = "Name of the Lambda layer"
  value       = aws_lambda_layer_version.this.layer_name
}

output "compatible_runtimes" {
  description = "Compatible runtimes for the Lambda layer"
  value       = aws_lambda_layer_version.this.compatible_runtimes
}

output "source_code_hash" {
  description = "Base64 encoded SHA256 hash of the layer source code"
  value       = aws_lambda_layer_version.this.source_code_hash
}
