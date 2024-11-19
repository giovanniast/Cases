output "name" {
  value = [for v in aws_cloudwatch_log_group.main : v.name]
}

