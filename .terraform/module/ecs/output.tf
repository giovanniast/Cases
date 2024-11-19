output "cluster-name" {
  value = aws_ecs_cluster.main.name
}
output "cluster-arn" {
  value = aws_ecs_cluster.main.arn
}
output "service-name" {
  value = aws_ecs_service.main
}
