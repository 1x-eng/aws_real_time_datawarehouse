locals {
  zip_location         = "lambda_zip/${var.lambda_name}.zip"
  lambda_function_name = "dw_${var.env}_${var.lambda_name}"
}

data "archive_file" "lambda_archive" {
  type        = "zip"
  source_file = "lambda_logic/${var.logic_file_name}.${var.logic_file_extension}"
  output_path = local.zip_location
}

resource "aws_lambda_function" "dw_lambda" {
  count = var.create ? 1 : 0

  filename         = local.zip_location
  function_name    = local.lambda_function_name
  role             = var.lambda_iam_arn
  handler          = "${var.logic_file_name}.handler"
  source_code_hash = data.archive_file.lambda_archive.output_base64sha256
  runtime          = var.runtime
  timeout          = var.timeout
  tracing_config {
    mode = var.lambda_tracing_config // Can be PassThrough or Active
  }
  tags = var.default_tags
}