output "info" {
  value = [for v in aws_elasticache_replication_group.main :
  "${v.id}, ${v.engine_version_actual}"]
}
output "endpoint" {
  value = [for v in aws_elasticache_replication_group.main :
  v.primary_endpoint_address]
}
