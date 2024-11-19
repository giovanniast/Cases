resource "aws_appautoscaling_target" "main" {
  for_each           = var.ecs_autoscaling_config
  max_capacity       = each.value.max_capacity
  min_capacity       = each.value.min_capacity
  resource_id        = "service/${var.ecs_cluster_name}/${var.aws_prefix}-${var.aws_project}-${replace(each.key, "/", "-")}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  for_each           = { for k, v in var.ecs_autoscaling_config : "${k}-cpu" => v }
  name               = try(each.value.name, replace(each.key, "/", "-"))
  policy_type        = try(each.value.policy_type, "TargetTrackingScaling")
  resource_id        = aws_appautoscaling_target.main[replace("${each.key}", "/(-cpu+)/", "")].resource_id
  scalable_dimension = aws_appautoscaling_target.main[replace("${each.key}", "/(-cpu+)/", "")].scalable_dimension
  service_namespace  = aws_appautoscaling_target.main[replace("${each.key}", "/(-cpu+)/", "")].service_namespace

  dynamic "target_tracking_scaling_policy_configuration" {
    for_each = { for k, v in each.value : k => v if k == "cpu" }
    content {
      target_value       = target_tracking_scaling_policy_configuration.value.target_value
      scale_in_cooldown  = target_tracking_scaling_policy_configuration.value.scale_in_cooldown
      scale_out_cooldown = target_tracking_scaling_policy_configuration.value.scale_out_cooldown
      dynamic "predefined_metric_specification" {
        for_each = { for k, v in each.value : k => v if k == "cpu" }
        content {
          predefined_metric_type = predefined_metric_specification.value.predefined_metric_type
          resource_label         = each.key == "alb" ? one([for k, v in var.target_group : v if k == predefined_metric_specification.value.resource_label]) : null
        }
      }
    }
  }

  depends_on = [
    aws_appautoscaling_target.main
  ]
}

resource "aws_appautoscaling_policy" "alb" {
  for_each           = { for k, v in var.ecs_autoscaling_config : "${k}-alb" => v }
  name               = try(each.value.type, replace(each.key, "/", "-"))
  policy_type        = try(each.value.policy_type, "TargetTrackingScaling")
  resource_id        = aws_appautoscaling_target.main[replace("${each.key}", "/(-alb+)/", "")].resource_id
  scalable_dimension = aws_appautoscaling_target.main[replace("${each.key}", "/(-alb+)/", "")].scalable_dimension
  service_namespace  = aws_appautoscaling_target.main[replace("${each.key}", "/(-alb+)/", "")].service_namespace

  dynamic "target_tracking_scaling_policy_configuration" {
    for_each = flatten([for k, v in each.value : v if k == "alb"])
    content {
      target_value       = target_tracking_scaling_policy_configuration.value.target_value
      scale_in_cooldown  = target_tracking_scaling_policy_configuration.value.scale_in_cooldown
      scale_out_cooldown = target_tracking_scaling_policy_configuration.value.scale_out_cooldown
      dynamic "predefined_metric_specification" {
        for_each = flatten([for k, v in each.value : v if k == "alb"])
        content {
          predefined_metric_type = predefined_metric_specification.value.predefined_metric_type
          resource_label         = one([for k, v in var.target_group : v if k == predefined_metric_specification.value.resource_label])
        }
      }
    }
  }

  depends_on = [
    aws_appautoscaling_target.main
  ]
}

# resource "aws_appautoscaling_policy" "mem" {
#   for_each           = { for k, v in var.ecs_autoscaling_config : "${k}-mem" => v }
#   name               = try(each.value.name, replace(each.key, "/", "-"))
#   policy_type        = try(each.value.policy_type, "TargetTrackingScaling")
#   resource_id        = aws_appautoscaling_target.main[replace("${each.key}", "/(-mem+)/", "")].resource_id
#   scalable_dimension = aws_appautoscaling_target.main[replace("${each.key}", "/(-mem+)/", "")].scalable_dimension
#   service_namespace  = aws_appautoscaling_target.main[replace("${each.key}", "/(-mem+)/", "")].service_namespace

#   dynamic "target_tracking_scaling_policy_configuration" {
#     for_each = { for k, v in each.value : k => v if k == "mem" }
#     content {
#       target_value       = target_tracking_scaling_policy_configuration.value.target_value
#       scale_in_cooldown  = target_tracking_scaling_policy_configuration.value.scale_in_cooldown
#       scale_out_cooldown = target_tracking_scaling_policy_configuration.value.scale_out_cooldown
#       dynamic "predefined_metric_specification" {
#         for_each = { for k, v in each.value : k => v if k == "mem" }
#         content {
#           predefined_metric_type = predefined_metric_specification.value.predefined_metric_type
#           resource_label         = each.key == "alb" ? one([for k, v in var.target_group : v if k == predefined_metric_specification.value.resource_label]) : null
#         }
#       }
#     }
#   }

#   depends_on = [
#     aws_appautoscaling_target.main
#   ]
# }
