variable "region_of_operation" {
  default = "ap-southeast-2"
}
variable "env" {}

# Default tags
variable "default_tags" {
  type = map
  default = {
    created_by = "terraform",
    managed_by = "terraform",
    owner      = "terraform/admin"
  }
}

# Create variables - controlled by environment variables.
variable "create_transient_storage" {
  default = false
}
variable "create_lambda_pre_processor" {
  default = false
}
variable "create_kinesis_firehose" {
  default = false
}
variable "create_glue_catalog" {
  default = false
}
variable "create_etl_script_storage" {
  default = false
}
variable "upload_etl_script" {
  default = false
}
variable "create_glue_etl" {
  default = false
}
variable "create_glue_trigger" {
  default = false
}
variable "create_lambda_glue_job_trigger" {
  default = false
}
variable "create_cloudwatch_event_trigger_for_lambda" {
  default = false
}
variable "create_data_lake_storage" {
  default = false
}
variable "create_athena_storage_bucket" {
  default = false
}
variable "create_athena_over_datalake" {
  default = false
}

# Storage - block public access
variable "block_public_access_to_storage" {
  type = map
  default = {
    acls   = true
    policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
  }
}

# Transient Storage - Bucket details.
variable "transient_storage_bucket_name" {}

#Lambda generic
variable "lambda_tracing_config" {}

# PreProcessor Lambda - details.
variable "pre_processor_lambda_policy_prefix" {} # MUST match the syntax of file name inside `policies` folder. (SYNTAX = <value>_policy.json & <value>_role_policy.json)
variable "pre_processor_lambda_name" {
  default = "pre_processor"
}
variable "pre_processor_lambda_logic_file_name" {} # location = ./lambda_logic/

# Kinesis Firehose - details.
variable "kinesis_firehose_component_name" {
  default = "kinesis_firehose"
}

# Glue catalog - details.
variable "create_glue_catalog_crawler_on_schedule" {
  default = false
}
variable "glue_catalog_component_name" {
  default = "glue_catalog"
}
variable "glue_catalog_target_database_name" {}
variable "glue_catalog_crawler_name" {}

# Glue ETL Job.
variable "glue_etl_component_name" {
  default = "glue_etl"
}
variable "glue_etl_script_remote_bucket_name" {
  default = "glue-etl-script"
}
variable "glue_etl_object_name" {}
variable "glue_etl_local_file_name" {} # Must be name of a file inside `/etl_logic` directory
variable "glue_etl_temp_storage_bucket_name" {
  default = "glue-etl-temp-storage"
}
variable "glue_etl_job_name" {}
variable "glue_etl_job_description" {}
variable "glue_etl_temp_directory_name" {
  default = "_temp_glue_etl"
}
variable "glue_etl_bookmarks_for_tracking_processed_data" {
  default = "disabled" # Options = enabled / disabled / paused https://docs.aws.amazon.com/glue/latest/dg/monitor-continuations.html
}
variable "glue_etl_config" {
  type = object({
    max_retries         = number
    timeout             = number
    max_concurrent_runs = number
  })

  default = {
    max_retries         = 0
    timeout             = 2800
    max_concurrent_runs = 1
  }
}

# Glue Trigger
variable "glue_trigger_name" {}

# Glue Trigger Lambda - details
variable "glue_job_trigger_lambda_policy_prefix" {} # location = ./lambda_logic/
variable "glue_job_trigger_lambda_name" {
  default = "glue_trigger"
}
variable "glue_job_trigger_lambda_logic_file_name" {} # location = ./lambda_logic/
variable "glue_job_trigger_lambda_run_time" {
  default = "python3.8"
}
variable "glue_job_trigger_lambda_file_extension" {
  default = "py"
}

# Cloudwatch events - rule - to trigger Lambda for Glue ETL
variable "cloudwatch_event" {
  type = map
  default = {
    rule_name        = "trigger"
    rule_description = "Cloudwatch event rule used as a trigger"
    target_unique_id = "cw-event-trigger"
  }
}

# Datalake storage bucket 
variable "data_lake_storage_bucket_name" {
  default = "data_lake"
}

# Glue crawler for cataloging post-ETL data
variable "create_glue_catalog_for_post_etl" {
  default = false
}
variable "glue_catalog_post_etl_target_database_name" {}
variable "glue_catalog_post_etl_crawler_name" {}

# Athena query storage bucket
variable "athena_storage_bucket_name" {}

# Athena over datalake
variable "athena_database_name" {}

