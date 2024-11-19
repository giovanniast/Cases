output "dns_name" {
  value = aws_lb.main.dns_name
}
output "zone_id" {
  value = aws_lb.main.zone_id
}
output "nlb_dns_name" {
  value = aws_lb.apigateway[0].dns_name
}
output "nlb_zone_id" {
  value = aws_lb.apigateway[0].zone_id
}
output "id" {
  value = aws_lb.main.name
}
output "autoscaling" {
  value = { for k, v in aws_lb_target_group.main : k => "${aws_lb.main.arn_suffix}/${v.arn_suffix}" }
}
output "arn" {
  value = { for k, v in aws_lb_target_group.main : k => v.arn }
}
output "ecs_nlb_arn" {
  value = { for k, v in aws_lb_target_group.apigateway : k => v.arn }
}
output "aws_lb_listener-http-arn" {
  value = aws_lb_listener.http.arn
}
output "aws_lb_listener_rule" {
  value = [for k, v in aws_lb_listener_rule.main : k]
}
output "tg_alb_arn" {
  value = [for k, v in aws_lb_target_group.main : v.arn]
}
output "nlb_arn" {
  #value = aws_lb.apigateway[0].arn
  value = [for k, v in aws_lb.apigateway : v.arn]
}
output "nlb_dns" {
  #value = aws_lb.apigateway[0].arn
  value = [for k, v in aws_lb.apigateway : v.dns_name]
}
output "alb_arn" {
  value = aws_lb.main.arn
}
