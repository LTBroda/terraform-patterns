locals {
  build_dir  = "${path.module}/build/${var.layer_name}"
  python_dir = "${local.build_dir}/python"

  compatible_runtimes = ["python${var.python_version}"]

  # Timestamp for triggering rebuilds when dependencies change
  requirements_hash   = fileexists(var.requirements_file) ? filemd5(var.requirements_file) : ""
  shared_modules_hash = var.shared_modules_path != null && fileexists(var.shared_modules_path) ? md5(join("", [for f in fileset(var.shared_modules_path, "**") : filemd5("${var.shared_modules_path}/${f}")])) : ""
  content_hash        = md5("${local.requirements_hash}-${local.shared_modules_hash}")
}
