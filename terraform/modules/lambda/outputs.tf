output "lambda_arn" {
  value = join("", aws_lambda_function.dw_lambda.*.arn)
}
output "lambda_function_name" {
  value = local.lambda_function_name
}