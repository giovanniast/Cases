data "aws_ecr_image" "service_image" {
  repository_name = var.ecr_name
  image_tag       = var.image_tag
}

resource "aws_ecs_cluster" "main" {
  name = "${var.aws_prefix}-${var.aws_project}-${var.aws_env}"
  tags = var.tag_project
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = false
        cloud_watch_log_group_name     = "/ssm/${var.aws_prefix}-${var.aws_project}-${var.aws_env}"
      }
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name
  capacity_providers = [
    "FARGATE",
    "FARGATE_SPOT"
  ]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
  }
  depends_on = [aws_ecs_cluster.main]
}

#Armazena arn
data "aws_secretsmanager_secret" "secrets" {
  arn = var.secretsmanager_app_arn
}
#Armazena id
data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}
#Armazena keys
locals {
  secrets_keys = keys(jsondecode(nonsensitive(data.aws_secretsmanager_secret_version.current.secret_string)))
}
#Tratamento dos valores para task_definition
locals {
  auto_secrets = [for secret_key in local.secrets_keys :
  zipmap(["name", "valueFrom"], ["${secret_key}", "${var.secretsmanager_app_arn}:${secret_key}::"])]
}

data "template_file" "main" {
  template = file("./templates/ecs/image.json")
  for_each = var.config_ecs
  vars = {
    app_image      = var.disable_deploy ? "${var.ecr_repository}:${data.aws_ecr_image.service_image.image_tag}" : "${var.ecr_repository}:${data.aws_ecr_image.service_image.image_tag}@${data.aws_ecr_image.service_image.image_digest}"
    port_app       = var.port_app
    fargate_cpu    = each.value.cpu
    fargate_memory = each.value.memory
    aws_region     = var.aws_region
    aws_project    = var.aws_project
    list_secrets   = jsonencode(local.auto_secrets)
    awslogs_group  = "/ecs/${var.aws_project}/${var.aws_prefix}-${var.aws_project}-${each.key}"
    command        = join(",", formatlist("\"%s\"", each.value.command))
  }
  depends_on = [
    data.aws_ecr_image.service_image
  ]
}


resource "aws_ecs_task_definition" "main" {
  for_each                 = var.config_ecs
  family                   = "${var.aws_prefix}-${var.aws_project}-${replace(each.key, "/", "-")}"
  execution_role_arn       = var.ecs_role_arn
  task_role_arn            = var.ecs_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  container_definitions    = data.template_file.main[each.key].rendered
  skip_destroy             = true
  tags                     = var.tag_project
}

resource "aws_ecs_service" "main" {
  for_each                          = var.config_ecs
  name                              = "${var.aws_prefix}-${var.aws_project}-${replace(each.key, "/", "-")}"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = var.disable_deploy ? data.aws_ecs_service.migrate[each.key].task_definition : aws_ecs_task_definition.main[each.key].arn
  desired_count                     = "1"
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = each.value.target_group_arn == true ? each.value.health_check_grace : null
  force_new_deployment              = var.disable_deploy ? true : false
  enable_execute_command            = true
  propagate_tags                    = try(each.value.propagate_tags, "TASK_DEFINITION")

  tags = var.tag_project

  network_configuration {
    security_groups  = [var.security_groups]
    subnets          = var.subnet_priv
    assign_public_ip = false
  }

  dynamic "load_balancer" {
    for_each = each.value.target_group_arn ? [1] : []

    content {
      target_group_arn = var.target_group_arn[each.key]
      container_name   = var.aws_project
      container_port   = var.port_app
    }

  }

  dynamic "load_balancer" {
    for_each = each.value.target_group_nlb_arn ? [1] : []

    content {
      target_group_arn = var.target_group_nlb_arn[each.key]
      container_name   = var.aws_project
      container_port   = var.port_app
    }

  }

  lifecycle {
    ignore_changes = [
      desired_count,
      capacity_provider_strategy,
      launch_type
    ]
  }

  depends_on = [
    aws_ecs_task_definition.main,
    aws_ecs_cluster.main
  ]
}
