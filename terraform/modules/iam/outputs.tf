output "iam_arn" {
  value = join("", aws_iam_role.dw_iam_role.*.arn)
}