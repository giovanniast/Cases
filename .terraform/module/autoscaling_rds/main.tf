resource "aws_appautoscaling_target" "rds" {
  for_each           = var.rds_autoscaling_config
  max_capacity       = each.value.max_capacity
  min_capacity       = each.value.min_capacity
  resource_id        = "cluster:${one(var.rds_name)}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "cpu" {
  for_each           = { for k, v in var.rds_autoscaling_config : "${k}-cpu" => v }
  name               = try(each.value.name, replace(each.key, "/", "-"))
  policy_type        = try(each.value.policy_type, "TargetTrackingScaling")
  resource_id        = aws_appautoscaling_target.rds[replace("${each.key}", "/(-cpu+)/", "")].resource_id
  scalable_dimension = aws_appautoscaling_target.rds[replace("${each.key}", "/(-cpu+)/", "")].scalable_dimension
  service_namespace  = aws_appautoscaling_target.rds[replace("${each.key}", "/(-cpu+)/", "")].service_namespace

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
        }
      }
    }
  }

  depends_on = [
    aws_appautoscaling_target.rds
  ]

}
