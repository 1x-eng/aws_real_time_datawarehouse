locals {
  table_prefix = var.table_prefix
}

resource "aws_glue_crawler" "dw_glue_crawler" {
  count = var.create ? 1 : 0

  database_name = var.target_database_name
  name          = "dw_${var.env}_glue_crawler_${var.crawler_name}"
  role          = var.crawler_iam_role_arn

  s3_target {
    path = "s3://${var.crawler_s3_source}"
  }

  schedule     = "cron(${var.cron_schedule})"
  table_prefix = var.table_prefix
  tags         = var.default_tags
}