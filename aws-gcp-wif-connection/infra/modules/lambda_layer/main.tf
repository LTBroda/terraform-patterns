# Create build directory and install dependencies
resource "null_resource" "build_layer" {
  triggers = {
    content_hash = local.content_hash
  }

  provisioner "local-exec" {
    command = <<-EOT
      set -e

      # Clean and create build directory
      rm -rf ${local.build_dir}
      mkdir -p ${local.python_dir}

      # Install Python dependencies
      if [ -f "${var.requirements_file}" ]; then
        echo "Installing dependencies from ${var.requirements_file}..."
        pip install -r ${var.requirements_file} -t ${local.python_dir} \
          --platform manylinux2014_x86_64 \
          --only-binary=:all: \
          --upgrade \
          --no-cache-dir
      fi

      # Copy shared modules if provided
      if [ -n "${var.shared_modules_path != null ? var.shared_modules_path : ""}" ] && [ -d "${var.shared_modules_path != null ? var.shared_modules_path : ""}" ]; then
        echo "Copying shared modules from ${var.shared_modules_path != null ? var.shared_modules_path : ""}..."
        cp -r ${var.shared_modules_path != null ? var.shared_modules_path : ""}/* ${local.python_dir}/
      fi

      echo "Layer build completed successfully"
    EOT
  }
}

# Lambda Layer
resource "aws_lambda_layer_version" "this" {
  filename            = data.archive_file.layer_zip.output_path
  layer_name          = var.layer_name
  description         = var.description
  compatible_runtimes = local.compatible_runtimes
  source_code_hash    = data.archive_file.layer_zip.output_base64sha256

  license_info = var.license_info != "" ? var.license_info : null

  depends_on = [null_resource.build_layer]
}
