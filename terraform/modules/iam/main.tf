# Pre-requisite:
# 1. Generate policy.json & role_policy.json wrt aws component & their desired access
# 2. Store the JSON file with <aws_component_name>_policy.json & <aws_component_name>_role_policy.json & store within `policies` folder in `terraform` root.
# eg. Kinesis Firehose will have a policy named as kinesis_firehose_policy.json & kinesis_firehose_role_policy.json

resource "aws_iam_role" "dw_iam_role" {
  count = var.create ? 1 : 0

  name               = "dw_${var.env}_${var.aws_component}_iam_role"
  assume_role_policy = file("policies/${var.aws_component}_policy.json")
  tags               = var.default_tags
}

resource "aws_iam_role_policy" "dw_iam_role_policy" {
  count = var.create ? 1 : 0

  name   = "dw_${var.env}_${var.aws_component}_iam_role_policy" #(Policy can be generated using AWS Policy Generator - https://awspolicygen.s3.amazonaws.com/policygen.html)
  role   = join("", aws_iam_role.dw_iam_role.*.name)
  policy = file("policies/${var.aws_component}_role_policy.json")
}