output "bucket_arn" {
  value = join("", aws_s3_bucket.dw_storage.*.arn)
}

output "bucket_path" {
  value = join("", aws_s3_bucket.dw_storage.*.bucket)
}

output "bucket_name" {
  value = join("", aws_s3_bucket.dw_storage.*.id)
}