output "name" {
  value = values(aws_rds_cluster.main).*.id
}
output "endpoint" {
  value = values(aws_rds_cluster.main).*.endpoint
}
output "reader_endpoint" {
  value = values(aws_rds_cluster.main).*.reader_endpoint
}
output "engine" {
  value = values(aws_rds_cluster.main).*.engine
}
output "engine_version" {
  value = values(aws_rds_cluster.main).*.engine_version
}
output "master_username" {
  value = values(aws_rds_cluster.main).*.master_username
}
output "database_name" {
  value = values(aws_rds_cluster.main).*.database_name
}
