resource "aws_athena_database" "dw_athena" {
  count = var.create ? 1 : 0

  name   = "dw_${var.env}_athena_${var.athena_database_name}"
  bucket = var.athena_query_results_storage_bucket_name
}