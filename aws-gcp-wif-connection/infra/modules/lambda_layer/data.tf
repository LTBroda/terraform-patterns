data "archive_file" "layer_zip" {
  type        = "zip"
  source_dir  = local.build_dir
  output_path = "${path.module}/build/${var.layer_name}.zip"

  depends_on = [null_resource.build_layer]
}
