output "list" {
  value = [for r in aws_iam_user.main : r.name]
}

output "list_access_key" {
  value = merge(
    { for k in var.iam_list : "AccessKey-${k}" => "${aws_iam_access_key.main[k].id}" },
    { for s in var.iam_list : "SecretKey-${s}" => "${aws_iam_access_key.main[s].secret}" }
  )
}

output "ecs_role_arn" {
  value = try(aws_iam_role.ecs_task_execution_role.arn, null)
}

output "ecs_role_name" {
  value = try(aws_iam_role.ecs_task_execution_role.name, null)
}


