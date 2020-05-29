variable "env" {}
variable "create" {
  default = false
}
variable "region_of_operation" {}
variable "rule_name" {}
variable "rule_description" {}
variable "associated_crawler_name" {}
variable "target_glue_job_name" {}
variable "arg_temp_storage_bucket_name_for_glue_job" {}
variable "arg_source_storage_bucket_name_for_glue_job" {}
variable "arg_destination_storage_bucket_name_for_glue_job" {}
variable "arg_source_storage_folder_prefix" {}
variable "arg_catalog_database_name" {}
variable "arg_catalog_table_name" {}
variable "arg_post_etl_crawler_name" {}
variable "target_unique_id" {}
variable "cloudwatch_lambda_event_target_arn" {}
variable "lambda_glue_job_trigger_function_name" {}
variable "default_tags" {
  type    = map
  default = {}
}