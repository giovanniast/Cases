# =======================================
#PROJECT
# =======================================

output "account-id" {
  value       = try(var.aws_account_id, null)
  description = "Account id template"
}

# =======================================
#NETWORK
# =======================================

output "subnet-priv-id" {
  value       = try(module.network[0].subnets-priv, null)
  description = "Subnet private id project"
}
output "subnet-pub-id" {
  value       = try(module.network[0].subnets-pub, null)
  description = "Subnet public id project"
}
output "nat-gateway-ip" {
  value       = try(module.network[0].nat-gateway-ip, null)
  description = "IP NAT project"
}
output "route-table-private" {
  value       = try(module.network[0].route-table-private, null)
  description = "Route Table id private project"
}
output "route-table-public" {
  value       = try(module.network[0].route-table-public, null)
  description = "Route Table id public project"
}
output "rds-subnet-group" {
  value       = try(module.network[0].rds-subnet-group-name, null)
  description = "Subnet Group id rds project"
}
output "elasticache-subnet-group-name" {
  value       = try(module.network[0].elasticache-subnet-group-name, null)
  description = "Subnet Group id elasticache project"
}

# =======================================
#SECURITY_GROUP
# =======================================

output "sg-alb" {
  value       = try(module.security-group[0].sg_alb-id, null)
  description = "Security Group id load balance project"
}
output "sg-app" {
  value       = try(module.security-group[0].sg_app-id, null)
  description = "Security Group id application ecs project"
}
output "sg-rds" {
  value       = try(module.security-group[0].sg_rds-id, null)
  description = "Security Group id rds project"
}
output "sg-redis" {
  value       = try(module.security-group[0].sg_redis-id, null)
  description = "Security Group id redis project"
}

# =======================================
#ALB
# =======================================

output "alb-dns-name" {
  value       = var.enable_alb ? module.alb[0].dns_name : null
  description = "DNS Load Balance project"
}
output "alb-tgs" {
  value       = var.enable_alb ? module.alb[0].arn : null
  description = "Arn Load Balance project"
}
output "alb-listener_rule" {
  value       = var.enable_alb ? module.alb[0].aws_lb_listener_rule : null
  description = "Rules name enable"
}
# =======================================
#SECRET_MANAGER
# =======================================

output "secret_manager_app_arn" {
  value       = var.enable_secretmanager ? module.secret-manager[0].app_arn : null
  description = "Secret manager application"
}
output "secret_manager_aim_arn" {
  value       = var.enable_secretmanager ? module.secret-manager[0].iam_arn : null
  description = "Secret manager iam"
}

# =======================================
#ECR
# =======================================

output "ecr-url" {
  value       = try(module.ecr[0].repository_url, null)
  description = "ECR url"
}

# =======================================
#IAM
# =======================================

output "iam-user-name" {
  value       = try(module.iam[0].list, null)
  description = "IAM Users name"
}
output "iam-role-ecs" {
  value       = try(module.iam[0].ecs_role_name, null)
  description = "IAM role name default ecs"
}
output "iam-role-arn" {
  value       = try(module.iam[0].ecs_role_arn, null)
  description = "IAM role arn default ecs"
}

# =======================================
#CLOUDWATCH
# =======================================

output "cloudwatch-ecs-name" {
  value       = try(module.cloudwatch[0].name, null)
  description = "Log Group name ECS"
}
output "cloudwatch-ssm-name" {
  value       = try(module.cloudwatch[0].ssm-name, null)
  description = "Log Group name SSM Cluster ECS"
}

# =======================================
#ECS
# =======================================

output "ecs-config" {
  value       = try(var.config_ecs, null)
  description = "Config Services ECS"
}
output "ecs-port" {
  value       = try(var.port_app, null)
  description = "Port Application ECS"
}
output "ecs-cluster-name" {
  value       = try(module.ecs[0].cluster-name, null)
  description = "Cluster name ECS"
}

# =======================================
#AUTO-SCALING
# =======================================

output "ecs-auto-scaling-cpu" {
  value       = try(module.autoscaling_ecs[0].config-cpu, null)
  description = "Auto scaling config CPU services ECS"
}
output "ecs-auto-scaling-alb" {
  value       = try(module.autoscaling_ecs[0].config-alb, null)
  description = "Auto scaling config ALB services ECS"
}
output "rds-auto-scaling" {
  value       = try(module.autoscaling_rds[0].config, null)
  description = "Auto scaling config CPU RDS"
}

# =======================================
#RDS
# =======================================

output "rds-endpoint-read" {
  value       = try(module.rds[0].reader_endpoint, null)
  description = "Endpoint read Cluster RDS"
}
output "rds-endpoint-write" {
  value       = try(module.rds[0].endpoint, null)
  description = "Endpoint write Cluster RDS"
}
output "rds-engine" {
  value       = try(module.rds[0].engine, null)
  description = "Engine Cluster RDS"
}
output "rds-engine_version" {
  value       = try(module.rds[0].engine_version, null)
  description = "Engine version Cluster RDS"
}

# =======================================
#ROUTE53
# =======================================

output "dns" {
  value       = var.aws_env == "production" ? try("https://${module.route53[0].fqdn}", null) : try("https://${module.route53[0].fqdn}", null)
  description = "Route53 FQDN"
}

# =======================================
#REDIS
# =======================================

output "elasticache-redis" {
  value       = try(module.redis[0].info, null)
  description = "Elasticache Redis Info (Name,type,version)"
}

# =======================================
#SQS
# =======================================

output "sqs" {
  value       = try(module.sqs[0].filas, null)
  description = "SQS queues name"
}
output "sqs-deadletter" {
  value       = try(module.sqs[0].filas-deadletter, null)
  description = "SQS queues deadletter name"
}

# =======================================
# VPC Endpoint
# =======================================

output "vpc_endpoint" {
  description = "endpoints"
  value       = try(module.vpc_endpoint[0].endpoints, null)
}

output "cloudfront-id-alb" {
  description = "id do cloudfront"
  value       = try(module.cloudfront_alb[0].id, null)
}