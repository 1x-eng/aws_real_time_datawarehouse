#####################################################################################################
# Create Transient Storage Bucket
#####################################################################################################
module "dw_transient_storage" {
  source = "./modules/bucket"

  create       = var.create_transient_storage
  env          = var.env
  bucket_name  = var.transient_storage_bucket_name
  default_tags = var.default_tags
  block_public = var.block_public_access_to_storage
}

#####################################################################################################
# Create IAM for PreProcessor Lambda
#####################################################################################################
module "dw_iam_lambda_pre_processor" {
  source = "./modules/iam"

  create        = var.create_lambda_pre_processor
  env           = var.env
  aws_component = var.pre_processor_lambda_policy_prefix
  default_tags  = var.default_tags
}

#####################################################################################################
# Create PreProcessor Lambda
#####################################################################################################
module "dw_lambda_pre_processor" {
  source = "./modules/lambda"

  create                = var.create_lambda_pre_processor
  env                   = var.env
  lambda_name           = var.pre_processor_lambda_name
  logic_file_name       = var.pre_processor_lambda_logic_file_name # location = ./lambda_logic/
  lambda_iam_arn        = module.dw_iam_lambda_pre_processor.iam_arn
  lambda_tracing_config = var.lambda_tracing_config
  default_tags          = var.default_tags
}

#####################################################################################################
# Create IAM for Kinesis Firehose
#####################################################################################################
module "dw_iam_kinesis_firehose" {
  source = "./modules/iam"

  create        = var.create_kinesis_firehose
  env           = var.env
  aws_component = var.kinesis_firehose_component_name
  default_tags  = var.default_tags
}

#####################################################################################################
# Create Kinesis Firehose
#####################################################################################################
module "dw_kinesis_firehose" {
  source = "./modules/kinesis_firehose"

  create       = var.create_kinesis_firehose
  env          = var.env
  role_arn     = module.dw_iam_kinesis_firehose.iam_arn
  bucket_arn   = module.dw_transient_storage.bucket_arn
  lambda_arn   = module.dw_lambda_pre_processor.lambda_arn
  default_tags = var.default_tags
}

#####################################################################################################
# Create IAM for Cataloging via Glue Crawler
#####################################################################################################
module "dw_iam_glule_cataloging" {
  source = "./modules/iam"

  create        = var.create_glue_catalog
  env           = var.env
  aws_component = var.glue_catalog_component_name
  default_tags  = var.default_tags
}

#####################################################################################################
# Create Glue Crawler
#####################################################################################################
module "dw_glue_crawler" {
  source = "./modules/glue_scheduled_crawler"

  create               = var.create_glue_catalog
  env                  = var.env
  target_database_name = var.glue_catalog_target_database_name
  crawler_name         = var.glue_catalog_crawler_name
  crawler_iam_role_arn = module.dw_iam_glule_cataloging.iam_arn
  crawler_s3_source    = module.dw_transient_storage.bucket_path
  default_tags         = var.default_tags
}

#####################################################################################################
# Create Storage Bucket for Python ETL Script
#####################################################################################################
module "dw_etl_script_storage" {
  source = "./modules/bucket"

  create       = var.create_etl_script_storage
  env          = var.env
  bucket_name  = var.glue_etl_script_remote_bucket_name
  default_tags = var.default_tags
  block_public = var.block_public_access_to_storage
}

#####################################################################################################
# Upload Glue ETL script (pyspark) to Storage Bucket - source for Glue ETL Job.
#####################################################################################################
module "dw_etl_script_upload" {
  source = "./modules/bucket_object"

  create               = var.upload_etl_script
  existing_bucket_name = module.dw_etl_script_storage.bucket_name
  object_name          = var.glue_etl_object_name
  etl_file_name        = var.glue_etl_local_file_name # Must be name of a file inside `/etl_logic` directory 
  default_tags         = var.default_tags
}

#####################################################################################################
# Create IAM for Glue ETL Job
#####################################################################################################
module "dw_iam_glule_etl" {
  source = "./modules/iam"

  create        = var.create_glue_etl
  env           = var.env
  aws_component = var.glue_etl_component_name
  default_tags  = var.default_tags
}

#####################################################################################################
# Create Storage Bucket for PySpark ETL Temp Files
#####################################################################################################
module "dw_etl_temp_storage" {
  source = "./modules/bucket"

  create       = var.create_glue_etl
  env          = var.env
  bucket_name  = var.glue_etl_temp_storage_bucket_name
  default_tags = var.default_tags
  block_public = var.block_public_access_to_storage
}

#####################################################################################################
# Create Glue ETL Job 
#####################################################################################################
module "dw_glue_etl" {
  source = "./modules/glue_job"

  create                           = var.create_glue_etl
  env                              = var.env
  glue_job_name                    = var.glue_etl_job_name
  glue_job_iam_role_arn            = module.dw_iam_glule_etl.iam_arn
  name_of_bucket_containing_script = module.dw_etl_script_storage.bucket_name
  script_file_name                 = module.dw_etl_script_upload.script_name
  glue_job_description             = var.glue_etl_job_description
  arguments                        = {}
  bookmark                         = var.glue_etl_bookmarks_for_tracking_processed_data
  temp_storage_bucket_name         = module.dw_etl_temp_storage.bucket_name
  temp_storage_directory_name      = var.glue_etl_temp_directory_name
  etl_config                       = var.glue_etl_config
  default_tags                     = var.default_tags
}

#####################################################################################################
# Create Glue Trigger 
#####################################################################################################
module "dw_glue_trigger" {
  source = "./modules/glue_job_trigger"

  create                      = var.create_glue_trigger
  env                         = var.env
  glue_trigger_name           = var.glue_trigger_name
  glue_job_to_trigger         = module.dw_glue_etl.glue_job_name
  predicate_glue_crawler_name = module.dw_glue_crawler.crawler_name
  default_tags                = var.default_tags
}

#####################################################################################################
# Lambda as Glue ETL Job trigger
#####################################################################################################
#####################################################################################################
# Create IAM for Glue ETL Trigger Lambda
#####################################################################################################
module "dw_iam_lambda_glue_job_trigger" {
  source = "./modules/iam"

  create        = var.create_lambda_glue_job_trigger
  env           = var.env
  aws_component = var.glue_job_trigger_lambda_policy_prefix
  default_tags  = var.default_tags
}

#####################################################################################################
# Create Glue ETL Trigger Lambda
#####################################################################################################
module "dw_lambda_glue_job_trigger" {
  source = "./modules/lambda"

  create                = var.create_lambda_glue_job_trigger
  env                   = var.env
  lambda_name           = var.glue_job_trigger_lambda_name
  logic_file_name       = var.glue_job_trigger_lambda_logic_file_name # location = ./lambda_logic/
  lambda_iam_arn        = module.dw_iam_lambda_glue_job_trigger.iam_arn
  runtime               = var.glue_job_trigger_lambda_run_time
  logic_file_extension  = var.glue_job_trigger_lambda_file_extension
  lambda_tracing_config = var.lambda_tracing_config
  default_tags          = var.default_tags
}

#####################################################################################################
# Create Data Lake Storage Bucket
#####################################################################################################
module "dw_data_lake" {
  source = "./modules/bucket"

  create       = var.create_data_lake_storage
  env          = var.env
  bucket_name  = var.data_lake_storage_bucket_name
  default_tags = var.default_tags
  block_public = var.block_public_access_to_storage
}

#####################################################################################################
# Create Glue Crawler to Catalog data post ETL
#####################################################################################################
module "dw_glue_crawler_post_etl" {
  source = "./modules/glue_ondemand_crawler"

  create               = var.create_glue_catalog_for_post_etl
  env                  = var.env
  target_database_name = var.glue_catalog_post_etl_target_database_name
  crawler_name         = var.glue_catalog_post_etl_crawler_name
  crawler_iam_role_arn = module.dw_iam_glule_cataloging.iam_arn
  crawler_s3_source    = module.dw_data_lake.bucket_path
  default_tags         = var.default_tags
}

#####################################################################################################
# Create Cloudwatch Event Rule to Trigger Glue ETL Trigger Lambda
#####################################################################################################
module "dw_lambda_cloudwatch_event_trigger_lambda" {
  source = "./modules/cloud_watch_events"

  create                                           = var.create_cloudwatch_event_trigger_for_lambda
  env                                              = var.env
  rule_name                                        = var.cloudwatch_event.rule_name
  rule_description                                 = var.cloudwatch_event.rule_description
  associated_crawler_name                          = module.dw_glue_crawler.crawler_name
  target_glue_job_name                             = module.dw_glue_etl.glue_job_name
  arg_temp_storage_bucket_name_for_glue_job        = module.dw_etl_temp_storage.bucket_name
  arg_source_storage_bucket_name_for_glue_job      = module.dw_transient_storage.bucket_name
  arg_destination_storage_bucket_name_for_glue_job = module.dw_data_lake.bucket_name
  arg_source_storage_folder_prefix                 = module.dw_kinesis_firehose.s3_folder_prefix
  arg_catalog_database_name                        = var.glue_catalog_target_database_name
  arg_catalog_table_name                           = "${module.dw_glue_crawler.catalog_table_prefix}${replace(module.dw_transient_storage.bucket_name, "-", "_")}"
  target_unique_id                                 = var.cloudwatch_event.target_unique_id
  cloudwatch_lambda_event_target_arn               = module.dw_lambda_glue_job_trigger.lambda_arn
  lambda_glue_job_trigger_function_name            = module.dw_lambda_glue_job_trigger.lambda_function_name
  region_of_operation                              = var.region_of_operation
  arg_post_etl_crawler_name                        = module.dw_glue_crawler_post_etl.crawler_name
  default_tags                                     = var.default_tags
}

#####################################################################################################
# Create Athena Storage Bucket
#####################################################################################################
module "dw_datalake_athena_storage" {
  source = "./modules/bucket"

  create       = var.create_athena_storage_bucket
  env          = var.env
  bucket_name  = var.athena_storage_bucket_name
  default_tags = var.default_tags
  block_public = var.block_public_access_to_storage
}

#####################################################################################################
# Create Athena over data lake
#####################################################################################################
module "dw_athena_over_datalake" {
  source = "./modules/athena"

  create                                   = var.create_athena_over_datalake
  env                                      = var.env
  athena_database_name                     = var.athena_database_name
  athena_query_results_storage_bucket_name = module.dw_datalake_athena_storage.bucket_name
}