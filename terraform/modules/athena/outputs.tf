output "athena_name" {
  value = join("", aws_athena_database.dw_athena.*.id)
}