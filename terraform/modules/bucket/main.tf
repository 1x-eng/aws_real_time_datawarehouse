resource "aws_s3_bucket" "dw_storage" {
  count = var.create ? 1 : 0

  bucket = "dw-${var.env}-${var.bucket_name}"
  acl    = var.bucket_privacy
  lifecycle_rule {
    id      = "TTL"
    enabled = var.ttl_enabled

    expiration {
      days = var.ttl_days
    }
  }
  tags = var.default_tags
}

resource "aws_s3_bucket_public_access_block" "dw_storage_block_public_access" {
  count = var.create ? 1 : 0

  bucket = join("", aws_s3_bucket.dw_storage.*.id)

  block_public_acls   = var.block_public.acls
  block_public_policy = var.block_public.policy
  ignore_public_acls = var.block_public.ignore_public_acls
  restrict_public_buckets = var.block_public.restrict_public_buckets
}