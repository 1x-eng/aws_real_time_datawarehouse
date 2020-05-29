resource "aws_cloudwatch_event_rule" "dw_cloudwatch_event_rule" {
  count = var.create ? 1 : 0

  name        = "dw_${var.env}_cloudwatch_event_rule_${var.rule_name}"
  description = var.rule_description

  event_pattern = <<PATTERN
{
    "detail-type": [
        "Glue Crawler State Change"
    ],
    "source": [
        "aws.glue"
    ],
    "detail": {
        "crawlerName": [
            "${var.associated_crawler_name}"
        ],
        "state": [
            "Succeeded"
        ]
    }
}
PATTERN
  tags          = var.default_tags
}

resource "aws_cloudwatch_event_target" "dw_cloudwatch_event_target" {
  count     = var.create ? 1 : 0
  rule      = join("", aws_cloudwatch_event_rule.dw_cloudwatch_event_rule.*.id)
  target_id = var.target_unique_id
  arn       = var.cloudwatch_lambda_event_target_arn
  input     = <<JSON
{
  "targetGlueJobName": "${var.target_glue_job_name}",
  "regionOfOperation": "${var.region_of_operation}",
  "tempStorageBucketName": "${var.arg_temp_storage_bucket_name_for_glue_job}",
  "sourceStorageBucketName": "${var.arg_source_storage_bucket_name_for_glue_job}",
  "destinationStorageBucketName": "${var.arg_destination_storage_bucket_name_for_glue_job}",
  "sourceStorageFolderPrefix": "${var.arg_source_storage_folder_prefix}",
  "catalogDatabaseName": "${var.arg_catalog_database_name}",
  "catalogTableName": "${var.arg_catalog_table_name}",
  "postEtlCrawlerName": "${var.arg_post_etl_crawler_name}"
}
JSON
}

resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_glue_job_triggeer" {
  count         = var.create ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_glue_job_trigger_function_name
  principal     = "events.amazonaws.com"
  source_arn    = join("", aws_cloudwatch_event_rule.dw_cloudwatch_event_rule.*.arn)
}