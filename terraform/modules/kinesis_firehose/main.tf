locals {
  s3_folder_prefix       = "${var.env}_kinesis_firehose_processed_"
  s3_folder_error_prefix = "${var.env}_kinesis_firehose_err_"
}

resource "aws_kinesis_firehose_delivery_stream" "dw_kinesis_firehose_stream" {
  count = var.create ? 1 : 0

  name        = "dw_${var.env}_kinesis_firehose_stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = var.role_arn
    bucket_arn = var.bucket_arn

    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${var.lambda_arn}:$LATEST"
        }
      }
    }

    prefix              = local.s3_folder_prefix
    error_output_prefix = local.s3_folder_error_prefix

    cloudwatch_logging_options {
      enabled         = "true"
      log_group_name  = "dw_${var.env}_kinesis_firehose_stream_log_group"
      log_stream_name = "dw_${var.env}_kinesis_firehose_stream_log_stream"
    }
  }
  tags = var.default_tags
}