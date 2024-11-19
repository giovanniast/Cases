resource "aws_cloudwatch_log_group" "redis" {
  for_each          = var.redis_list
  name              = "/redis/${each.key}"
  retention_in_days = 30
  tags              = var.tag_project
}

resource "aws_elasticache_replication_group" "main" {
  for_each                    = var.redis_list
  automatic_failover_enabled  = each.value.automatic_failover_enabled
  preferred_cache_cluster_azs = each.value.availability_zone
  replication_group_id        = each.key
  description                 = "redis ${each.key}"
  node_type                   = each.value.type
  num_cache_clusters          = each.value.num_cache_clusters
  subnet_group_name           = var.subnet_group_name
  parameter_group_name        = each.value.parameter_group
  engine                      = each.value.engine
  engine_version              = each.value.engine_version
  security_group_ids          = var.security_group_ids
  port                        = var.port_redis
  replicas_per_node_group     = each.value.replicas_per_node_group
  maintenance_window          = "sun:03:00-sun:05:00"
  snapshot_window             = "00:00-01:00"
  snapshot_retention_limit    = "3"
  apply_immediately           = true
  tags                        = var.tag_project

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis[each.key].name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.redis[each.key].name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }
}
