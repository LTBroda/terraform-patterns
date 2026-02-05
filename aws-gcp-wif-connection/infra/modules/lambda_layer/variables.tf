variable "layer_name" {
  description = "Name of the Lambda layer"
  type        = string
}

variable "description" {
  description = "Description of the Lambda layer"
  type        = string
  default     = ""
}

variable "python_version" {
  description = "Python version for the layer (e.g., 3.11, 3.12)"
  type        = string
  default     = "3.11"
}

variable "requirements_file" {
  description = "Path to requirements.txt file"
  type        = string
}

variable "shared_modules_path" {
  description = "Optional path to shared Python modules directory"
  type        = string
  default     = null
}

variable "license_info" {
  description = "License info for the layer"
  type        = string
  default     = ""
}
