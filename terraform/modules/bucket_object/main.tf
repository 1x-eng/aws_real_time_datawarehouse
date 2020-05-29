locals {
  script_name      = var.etl_file_name
  script_extension = var.etl_file_extension
}

resource "aws_s3_bucket_object" "dw_s3_object" {
  count = var.create ? 1 : 0

  bucket = var.existing_bucket_name
  key    = "${var.object_name}.${local.script_extension}"
  source = "etl_logic/${local.script_name}.${local.script_extension}"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("etl_logic/${local.script_name}.${local.script_extension}")
  tags = var.default_tags
}