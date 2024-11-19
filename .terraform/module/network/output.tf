
output "subnets-priv" {
  value = aws_subnet.subnets_priv[*].id
}
output "subnets-pub" {
  value = aws_subnet.subnets_pub[*].id
}
output "nat-gateway-ip" {
  value = aws_eip.main.public_ip
}
output "route-table-private" {
  value = aws_route_table.rt_priv.id
}
output "route-table-public" {
  value = var.rt_pub == null ? aws_route_table.rt_pub[0].id : var.rt_pub
}

#RDS
output "rds-subnet-group-name" {
  value = [for v in aws_db_subnet_group.main_rds : v.name]
}

#ELASTICACHE
output "elasticache-subnet-group-name" {
  value = var.enable_redis ? aws_elasticache_subnet_group.main_redis[0].name : null
  #value = [for v in aws_elasticache_subnet_group.main_redis : v.name]
  # value = aws_elasticache_subnet_group[0].main_redis.name
}
