variable "env" {}
variable "aws_component" {}
variable "create" {
  default = false
}
variable "default_tags" {
  type    = map
  default = {}
}