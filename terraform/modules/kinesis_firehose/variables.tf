variable "create" {
  default = false
}
variable "env" {}
variable "role_arn" {}
variable "bucket_arn" {}
variable "lambda_arn" {}
variable "default_tags" {
  type    = map
  default = {}
}