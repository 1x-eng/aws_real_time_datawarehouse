variable "env" {}
variable "create" {
  default = false
}
variable "lambda_name" {}
variable "logic_file_name" {}
variable "logic_file_extension" {
  default = "js"
}
variable "lambda_iam_arn" {}
variable "runtime" {
  default = "nodejs12.x"
}
variable "timeout" {
  default = "60"
}
variable "lambda_tracing_config" {
  default = "PassThrough" // Can be PassThrough or Active
}
variable "default_tags" {
  type    = map
  default = {}
}