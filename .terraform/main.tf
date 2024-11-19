module "alb" {
  source                    = "./module/alb"
  count                     = var.enable_alb ? 1 : 0
  tag_project               = var.tag_project
  alb_internal              = var.alb_internal
  subnet_priv               = module.network[0].subnets-priv
  subnet_pub                = module.network[0].subnets-pub
  bucket_log                = var.bucket_log
  aws_prefix                = var.aws_prefix
  aws_project               = var.aws_project
  port_app                  = var.port_app
  type_alb                  = var.type_alb
  vpc_id                    = var.vpc_id
  random_value              = lower(random_id.tg-name.hex)
  aws_cert                  = var.aws_cert
  additional_certs          = var.additional_certs
  security_groups           = [module.security-group[0].sg_alb-id]
  config_alb                = var.config_alb
  config_nlb                = var.config_nlb
  enable_apigateway_private = var.enable_apigateway_private
  alpn_policy               = var.alpn_policy
  depends_on = [
    module.network,
    module.security-group
  ]
}

module "iam" {
  source = "./module/iam"
  count  = var.enable_iam ? 1 : 0
  providers = {
    aws.dns = aws.dns
    aws     = aws
  }
  aws_project           = var.aws_project
  tag_project           = var.tag_project
  iam_list              = var.iam_list
  aws_env               = var.aws_env
  aws_prefix            = var.aws_prefix
  enable_scheduled_task = var.enable_scheduled_task
  aws_cicd              = var.aws_cicd
}

module "autoscaling_ecs" {
  source                 = "./module/autoscaling_ecs"
  count                  = var.enable_ecs && var.enable_autoscaling_ecs ? 1 : 0
  aws_project            = var.aws_project
  aws_prefix             = var.aws_prefix
  target_group           = module.alb[0].autoscaling
  ecs_autoscaling_config = var.ecs_autoscaling_config
  ecs_cluster_name       = module.ecs[0].cluster-name
  depends_on = [
    module.ecs,
    module.alb
  ]
}

module "autoscaling_rds" {
  source                 = "./module/autoscaling_rds"
  count                  = var.enable_rds && var.enable_autoscaling_rds ? 1 : 0
  aws_project            = var.aws_project
  aws_prefix             = var.aws_prefix
  rds_autoscaling_config = var.rds_autoscaling_config
  rds_name               = module.rds[0].name
  depends_on = [
    module.rds
  ]
}

module "network" {
  source                 = "./module/network"
  count                  = var.enable_network ? 1 : 0
  rt_pub                 = var.rt_pub
  aws_project            = var.aws_project
  aws_prefix             = var.aws_prefix
  tag_project            = var.tag_project
  vpc_id                 = var.vpc_id
  igw                    = var.igw
  mask_priv              = var.mask_priv
  mask_pub               = var.mask_pub
  cidr_priv              = var.cidr_priv
  cidr_pub               = var.cidr_pub
  enable_rds             = var.enable_rds
  enable_redis           = var.enable_redis
  config_rds             = var.config_rds
  aws_env                = var.aws_env
  rt-priv-peering        = var.rt-priv-peering
  rt-pub-peering         = var.rt-pub-peering
  aws_vpn_gateway        = var.aws_vpn_gateway
  route_propagation_priv = var.route_propagation_priv
  route_propagation_pub  = var.route_propagation_pub
}

module "security-group" {
  source               = "./module/security-group"
  count                = var.enable_security-group ? 1 : 0
  vpc_id               = var.vpc_id
  tag_project          = var.tag_project
  aws_project          = var.aws_project
  aws_prefix           = var.aws_prefix
  enable_rds           = var.enable_rds
  enable_alb           = var.enable_alb
  enable_redis         = var.enable_redis
  enable_vpc_link      = var.enable_vpc_link
  enable_vpc_endpoint  = var.enable_vpc_endpoint
  port_app             = var.port_app
  port_rds             = var.port_rds
  port_redis           = var.port_redis
  ingress_redis        = var.ingress_redis
  ingress_app          = var.ingress_app
  ingress_rds          = var.ingress_rds
  ingress_alb          = var.ingress_alb
  ingress_vpc_endpoint = var.ingress_vpc_endpoint
}

module "ecr" {
  source      = "./module/ecr"
  count       = var.enable_ecr ? 1 : 0
  aws_prefix  = var.aws_prefix
  aws_project = var.aws_project
  aws_env     = var.aws_env
  tag_project = var.tag_project
}

module "secret-manager" {
  count              = var.enable_secretmanager ? 1 : 0
  source             = "./module/secret-manager"
  aws_prefix         = var.aws_prefix
  aws_project        = var.aws_project
  aws_env            = var.aws_env
  tag_project        = var.tag_project
  list_secret_app = merge(
    var.var_project,
    local.vars
  )
  ###
  list_access_key = merge(module.iam[0].list_access_key, module.iam[0].iam_dns)
  depends_on = [
    module.iam,
    # aws_rds_cluster.main,
    random_password.password
  ]
}

module "cloudwatch" {
  source                    = "./module/cloudwatch"
  count                     = var.enable_cloudwatch ? 1 : 0
  aws_prefix                = var.aws_prefix
  enable_ecs                = var.enable_ecs
  tag_project               = var.tag_project
  aws_project               = var.aws_project
  aws_env                   = var.aws_env
  config_ecs                = var.config_ecs
}

module "ecs" {
  source                 = "./module/ecs"
  count                  = var.enable_ecs ? 1 : 0
  ecr_name               = module.ecr[0].name
  ecr_repository         = module.ecr[0].repository_url
  image_tag              = var.image_tag
  aws_prefix             = var.aws_prefix
  aws_project            = var.aws_project
  secretsmanager_app_arn = module.secret-manager[0].app_arn
  ecs_role_arn           = module.iam[0].ecs_role_arn
  config_ecs             = var.config_ecs
  security_groups        = module.security-group[0].sg_app-id
  subnet_priv            = module.network[0].subnets-priv
  target_group_arn       = module.alb[0].arn
  target_group_nlb_arn   = module.alb[0].ecs_nlb_arn
  port_app               = var.port_app
  aws_region             = var.aws_region
  tag_project            = var.tag_project
  aws_env                = var.aws_env
  disable_deploy         = var.disable_deploy
  depends_on = [
    module.alb,
    module.cloudwatch,
    module.secret-manager,
    module.iam,
    module.network,
    module.ecr
  ]
}

module "rds" {
  source                 = "./module/rds"
  count                  = var.enable_rds ? 1 : 0
  enable_rds             = var.enable_rds
  aws_prefix             = var.aws_prefix
  aws_project            = var.aws_project
  aws_env                = var.aws_env
  tag_project            = var.tag_project
  master_password        = try(var.password_rds, random_password.password.result)
  port_rds               = var.port_rds
  config_rds             = var.config_rds
  mask_priv              = var.mask_priv
  vpc_security_group_ids = module.security-group[0].sg_rds-id
  depends_on = [
    module.security-group,
    module.network
  ]
}

module "route53" {
  source                 = "./module/route53"
  count                  = var.enable_route53 ? 1 : 0
  providers = {
    aws.servico-ti = aws.dns
    aws            = aws
  }
  alias_name             = try(module.apigatewayv2[0].domain_name_target_domain_name, module.alb[0].dns_name)
  alias_zone_id          = try(module.apigatewayv2[0].domain_name_hosted_zone_id, module.alb[0].zone_id)
  aws_zoneid             = var.aws_zoneid
  aws_project            = var.aws_project
  aws_zoneid_private     = var.aws_zoneid_private
  aws_env                = var.aws_env
  enable_route53_private = var.enable_route53_private
  route53_records        = var.route53_records
  cloudfront_name        = try(one(module.cloudfront_s3[0].domain_name), null)
  cloudfront_name_alb    = try(one(module.cloudfront_alb[0].domain_name), null)
  cloudfront_zone_id_alb = try(one(module.cloudfront_alb[0].hosted_zone_id), null)
  depends_on = [
    module.alb
  ]
}

module "redis" {
  count             = var.enable_redis ? 1 : 0
  source            = "./module/redis"
  tag_project       = var.tag_project
  redis_list        = var.redis_list
  port_redis        = var.port_redis
  subnet_group_name = module.network[0].elasticache-subnet-group-name
  security_group_ids = [
    module.security-group[0].sg_redis-id
  ]
  depends_on = [
    module.network,
    module.security-group
  ]
}

module "sqs" {
  source               = "./module/sqs"
  count                = var.enable_sqs ? 1 : 0
  tag_project          = var.tag_project
  filas-sqs            = var.filas-sqs
  filas-sqs-deadletter = var.filas-sqs-deadletter
}

module "vpc_endpoint" {
  source             = "./module/vpc_endpoint"
  count              = var.enable_vpc_endpoint ? 1 : 0
  vpc_id             = var.vpc_id
  endpoints          = var.endpoints
  security_group_ids = [module.security-group[0].sg_vpc_endpoint-id]
  subnet_ids         = module.network[0].subnets-priv
  route_table_ids    = [module.network[0].route-table-private]
  timeouts           = var.timeouts
  tags               = var.tag_project
  aws_project        = var.aws_project
  aws_env            = var.aws_env
  depends_on = [
    module.network,
    module.security-group
  ]
}

module "s3" {
  source                = "./module/s3"
  count                 = var.enable_s3 ? 1 : 0
  bunckets              = var.bunckets
  tag_project           = var.tag_project
  aws_account_id        = var.aws_account_id
  aws_project           = var.aws_project
  enable_cors           = var.enable_cors
  enable_static         = var.enable_static
}

module "cloudfront_alb" {
  source           = "./module/cloudfront_alb"
  count            = var.enable_cloudfront ? 1 : 0
  cloufront_config = var.cloufront_config_alb
  aws_cert         = var.aws_cert
  aws_prefix       = var.aws_prefix
  aws_project      = var.aws_project
  aws_env          = var.aws_env
  aws_region       = var.aws_region
  tag_project      = var.tag_project
  bucket_log       = var.bucket_log
  alb_dns_name     = module.alb[0].dns_name
}