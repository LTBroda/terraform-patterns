resource "null_resource" "build_layer" {
  triggers = {
    content_hash = local.content_hash
  }

  provisioner "local-exec" {
    command = "${path.module}/build_layer.sh ${local.build_dir} ${local.python_dir} ${var.requirements_file} ${var.shared_modules_path != null ? var.shared_modules_path : ""}"
  }
}

resource "aws_lambda_layer_version" "this" {
  filename            = data.archive_file.layer_zip.output_path
  layer_name          = var.layer_name
  description         = var.description
  compatible_runtimes = local.compatible_runtimes
  source_code_hash    = data.archive_file.layer_zip.output_base64sha256

  license_info = var.license_info != "" ? var.license_info : null

  depends_on = [null_resource.build_layer]
}
