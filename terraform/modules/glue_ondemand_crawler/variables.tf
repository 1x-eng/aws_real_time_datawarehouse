variable "env" {}
variable "create" {
  default = false
}
variable "target_database_name" {}
variable "crawler_name" {}
variable "crawler_iam_role_arn" {}
variable "crawler_s3_source" {}
variable "table_prefix" {
  default = "metadata_"
}
variable "default_tags" {
  type    = map
  default = {}
}