output "object_id" {
  value = join("", aws_s3_bucket_object.dw_s3_object.*.id)
}

output "object_etag" {
  value = join("", aws_s3_bucket_object.dw_s3_object.*.etag)
}

output "script_name" {
  value = local.script_name
}

output "script_extension" {
  value = local.script_extension
}