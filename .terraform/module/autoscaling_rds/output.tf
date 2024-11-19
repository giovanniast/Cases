output "config" {
  value = [
    for v in aws_appautoscaling_policy.cpu : {
      for k in v.target_tracking_scaling_policy_configuration :
      v.name => "target_value:${k.target_value}, scale_out_cooldown:${k.scale_in_cooldown}, scale_out_cooldown:${k.scale_out_cooldown}"
    }
  ]
}
