resource "aws_cloudwatch_log_group" "main" {
  for_each          = var.enable_ecs ? var.config_ecs : {}
  name              = "/ecs/${var.aws_project}/${var.aws_prefix}-${var.aws_project}-${each.key}"
  retention_in_days = 30
  tags              = var.tag_project
}

resource "aws_cloudwatch_log_group" "ssm" {
  count             = var.enable_ecs ? 1 : 0
  name              = "/ssm/${var.aws_prefix}-${var.aws_project}-${var.aws_env}"
  retention_in_days = 30
  tags              = var.tag_project
}

