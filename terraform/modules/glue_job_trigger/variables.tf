variable "create" {
  default = false
}
variable "env" {}
variable "glue_trigger_name" {}
variable "glue_job_to_trigger" {}
variable "predicate_glue_crawler_name" {}
variable "default_tags" {
  type    = map
  default = {}
}
