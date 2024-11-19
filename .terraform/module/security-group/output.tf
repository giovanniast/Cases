output "sg_rds-id" {
  value = var.enable_rds ? aws_security_group.rds[0].id : null
}
output "sg_redis-id" {
  value = var.enable_redis ? aws_security_group.redis[0].id : null
}
output "sg_apigatewayv2-id" {
  value = var.enable_apigatewayv2 && var.enable_vpc_link ? aws_security_group.apigatewayv2[0].id : null
}
output "sg_vpc_endpoint-id" {
  value = var.enable_vpc_endpoint ? aws_security_group.vpc_endpoint[0].id : null
}
output "sg_alb-id" {
  value = try(aws_security_group.alb[0].id, null)
}
output "sg_app-id" {
  value = aws_security_group.app.id
}
