variable "env" {}
variable "create" {
  default = false
}
variable "language" {
  default = "python"
}
variable "temp_storage_bucket_name" {}
variable "temp_storage_directory_name" {}
variable "glue_job_name" {}
variable "glue_job_iam_role_arn" {}
variable "name_of_bucket_containing_script" {}
variable "script_file_name" {}
variable "arguments" {
  type = object({})
}
variable "glue_job_description" {
  default = "AWS Glue ETL Job"
}
variable "bookmark_options" {
  type = object({
    enabled  = string
    disabled = string
    paused   = string
  })
  default = {
    enabled  = "job-bookmark-enable"
    disabled = "job-bookmark-disable"
    paused   = "job-bookmark-pause"
  }
}
variable "bookmark" {
  default     = "disabled" # https://docs.aws.amazon.com/glue/latest/dg/monitor-continuations.html
  description = "It can be enabled, disabled or paused."
}
variable "enable_continuos_cloudwatch_logs" {
  default = "true"
}
variable "enable_continuos_log_filter" {
  default = "true"
}
variable "etl_config" {
  type = object({
    max_retries         = number
    timeout             = number
    max_concurrent_runs = number
  })
}
variable "default_tags" {
  type    = map
  default = {}
}