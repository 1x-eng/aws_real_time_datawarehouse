variable "create" {
  default = false
}
variable "existing_bucket_name" {}
variable "object_name" {}
variable "etl_file_name" {}
variable "etl_file_extension" {
  default = "py"
}
variable "default_tags" {
  type    = map
  default = {}
}
