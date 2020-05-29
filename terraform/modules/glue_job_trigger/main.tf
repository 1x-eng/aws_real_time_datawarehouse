resource "random_string" "default_random_string" {
  length  = 6
  upper   = false
  lower   = true
  number  = false
  special = false
}

resource "aws_glue_workflow" "glue_workflow" {
  name = "dw_${var.env}_glue_workflow_${random_string.default_random_string.result}"
}

resource "aws_glue_trigger" "glue_job_trigger" {
  count = var.create ? 1 : 0

  name          = "dw_${var.env}_glue_job_trigger_${var.glue_trigger_name}"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.glue_workflow.name

  actions {
    job_name = var.glue_job_to_trigger # must be name of the glue job created. Refer outputs.tf in `glue_job` directory.
  }

  predicate {
    conditions {
      crawler_name = var.predicate_glue_crawler_name
      crawl_state  = "SUCCEEDED"
    }
  }
  tags = var.default_tags
}