variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
}

variable "description" {
  description = "Description of the Lambda function"
  type        = string
  default     = ""
}

variable "handler" {
  description = "Lambda function handler (e.g., index.handler)"
  type        = string
}

variable "python_version" {
  description = "Python runtime version (e.g., python3.11, python3.12)"
  type        = string
  default     = "python3.11"
}

variable "source_path" {
  description = "Path to the Lambda function source code directory"
  type        = string
}

variable "timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Map of environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

variable "layer_arns" {
  description = "List of Lambda Layer ARNs to attach to the function"
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to the Lambda function and related resources"
  type        = map(string)
  default     = {}
}

variable "iam_policy_statements" {
  description = "Additional IAM policy statements for the Lambda execution role"
  type = list(object({
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  default = []
}

variable "reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for this lambda function. -1 for unreserved"
  type        = number
  default     = -1
}
