output "function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.this.arn
}

output "function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.this.invoke_arn
}

output "role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda.arn
}

output "role_name" {
  description = "Name of the Lambda execution role"
  value       = aws_iam_role.lambda.name
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda.name
}

output "qualified_arn" {
  description = "Qualified ARN of the Lambda function (includes version)"
  value       = aws_lambda_function.this.qualified_arn
}

output "version" {
  description = "Latest published version of the Lambda function"
  value       = aws_lambda_function.this.version
}
