output "crawler_name" {
  value = join("", aws_glue_crawler.dw_glue_ondemand_crawler.*.id)
}

output "catalog_table_prefix" {
  value = local.table_prefix
}