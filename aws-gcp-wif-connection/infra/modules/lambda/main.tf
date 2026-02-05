# CloudWatch Log Group for Lambda function
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# IAM Role for Lambda execution
resource "aws_iam_role" "lambda" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Additional IAM policy for Lambda (if provided)
resource "aws_iam_role_policy" "lambda_additional" {
  count = length(var.iam_policy_statements) > 0 ? 1 : 0
  name  = "${var.function_name}-additional-policy"
  role  = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for stmt in var.iam_policy_statements : {
        Effect   = stmt.effect
        Action   = stmt.actions
        Resource = stmt.resources
      }
    ]
  })
}

# Lambda Function
resource "aws_lambda_function" "this" {
  filename                       = data.archive_file.lambda_zip.output_path
  function_name                  = var.function_name
  role                          = aws_iam_role.lambda.arn
  handler                       = var.handler
  source_code_hash              = data.archive_file.lambda_zip.output_base64sha256
  runtime                       = var.python_version
  timeout                       = var.timeout
  memory_size                   = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  description                   = var.description
  layers                        = var.layer_arns

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.lambda,
    aws_iam_role_policy_attachment.lambda_basic
  ]

  tags = var.tags
}
