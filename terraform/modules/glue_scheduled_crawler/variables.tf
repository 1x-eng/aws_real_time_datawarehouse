variable "env" {}
variable "create" {
  default = false
}
variable "target_database_name" {}
variable "crawler_name" {}
variable "crawler_iam_role_arn" {}
variable "crawler_s3_source" {}

# Crawler can be made to run on-demand by letting lambda trigger; however, AWS glue crawler is only meant for "near real-time" backed by "Cron"
# This is because, if crawler is triggered while it is already running, it results in an error. 
# Hence, to start with going with a scheduled cron to scan every 15 mins. 
# If changing to anytime less than 12 mins, REMEMBER - GLUE ETL JOB That gets triggered post successful crawl has a cold start time of 10 to 12 min/job.
# Due to this cold start, there is a possibility of etl job not being able to be triggered by Lambda. 
# If schedule is reduced to less than 10 mins, remember to increase concurrency / max concurrent runs for Glue ETL Job.
variable "cron_schedule" {
  default = "0/15 * * * ? *"
}
variable "table_prefix" {
  default = "metadata_"
}
variable "default_tags" {
  type    = map
  default = {}
}