locals {
  default_arguments = {
    "--job-language"                     = var.language # Can only be Python or Scala.
    "--job-bookmark-option"              = lookup(var.bookmark_options, var.bookmark)
    "--TempDir"                          = "s3://${var.temp_storage_bucket_name}/${var.temp_storage_directory_name}" # should be complete s3 path to a directory that could be used for temp files while on job.
    "--continuous-log-logGroup"          = "${var.glue_job_name}_log_group"
    "--enable-continuous-cloudwatch-log" = var.enable_continuos_cloudwatch_logs
    "--enable-continuous-log-filter"     = var.enable_continuos_log_filter
    "--enable-metrics"                   = ""
  }
}

resource "aws_glue_job" "glue_job" {
  count = var.create ? 1 : 0

  name     = "dw_${var.env}_glue_job_${var.glue_job_name}"
  role_arn = var.glue_job_iam_role_arn

  command {
    script_location = "s3://${var.name_of_bucket_containing_script}/${var.script_file_name}.${var.language == "python" ? "py" : "sc"}"
  }

  # https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-etl-glue-arguments.html
  default_arguments = merge(local.default_arguments, var.arguments)

  description = var.glue_job_description
  max_retries = var.etl_config.max_retries
  timeout     = var.etl_config.timeout

  execution_property {
    max_concurrent_runs = var.etl_config.max_concurrent_runs
  }
  tags = var.default_tags
}