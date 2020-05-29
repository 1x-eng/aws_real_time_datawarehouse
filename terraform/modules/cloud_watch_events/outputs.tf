output "event_rule_name" {
  value = join("", aws_cloudwatch_event_rule.dw_cloudwatch_event_rule.*.id)
}

output "event_rule_arn" {
  value = join("", aws_cloudwatch_event_rule.dw_cloudwatch_event_rule.*.arn)
}