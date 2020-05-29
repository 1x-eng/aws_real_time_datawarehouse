variable "env" {}
variable "create" {
  default = false
}
variable "bucket_name" {}
variable "bucket_privacy" {
  default = "private"
}
variable "ttl_enabled" {
  default = true
}
variable "ttl_days" {
  default = 1
}
variable "default_tags" {
  type    = map
  default = {}
}
variable "block_public" {
  type = map
  default = {
    acls   = false
    policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
  }
}