# =======================================
#PROJECT
# =======================================

variable "aws_profile" {
  type        = string
  default     = ""
  description = "Profile AWS default"
}
variable "aws_profile_dns" {
  type        = string
  default     = ""
  description = "Profile other AWS DNS"
}
variable "aws_region" {
  type        = string
  default     = ""
  description = "Region account default AWS"
}
variable "aws_env" {
  type        = string
  default     = ""
  description = "Env application"
}
variable "aws_project" {
  type        = string
  default     = ""
  description = "Name project"
}
variable "aws_cicd" {
  type        = string
  default     = ""
  description = "CI/CD for prefix"
}
variable "aws_account_id" {
  type        = string
  default     = ""
  description = "Account default AWS template"
}
variable "aws_prefix" {
  type        = string
  default     = ""
  description = "Prefix default AWS template"
}
variable "tag_project" {
  type        = map(string)
  default     = {}
  description = "Tags all recursos AWS"
}

# =======================================
#ENABLE MODULOS
# =======================================

variable "enable_iam" {
  type        = bool
  default     = false
  description = "Enable or disable iam"
}
variable "enable_alb" {
  type        = bool
  default     = false
  description = "Enable or disable alb and tg"
}
variable "enable_autoscaling_ecs" {
  type        = bool
  default     = false
  description = "Enable or disable auto_autoscaling of the ecs"
}
variable "enable_autoscaling_rds" {
  type        = bool
  default     = false
  description = "Enable or disable auto_autoscaling of the rds"
}
variable "enable_network" {
  type        = bool
  default     = false
  description = "Enable or disable of the subnet, routa table, elastic ip, nat"
}
variable "enable_security-group" {
  type        = bool
  default     = false
  description = "Enable or disable of the security-group on rds, redis, ecs, alb"
}
variable "enable_ecr" {
  type        = bool
  default     = false
  description = "Enable or disable of the ecr"
}
variable "enable_rds" {
  type        = bool
  default     = false
  description = "Enable or disable of the rds"
}
variable "enable_secretmanager" {
  type        = bool
  default     = false
  description = "Enable or disable of the secretmanager"
}
variable "enable_cloudwatch" {
  type        = bool
  default     = false
  description = "Enable or disable of the cloudwatch"
}
variable "enable_ecs" {
  type        = bool
  default     = false
  description = "Enable or disable of the cloudwatch"
}
variable "enable_route53" {
  type        = bool
  default     = false
  description = "Enable or disable of the route53"
}
variable "enable_sqs" {
  type        = bool
  default     = false
  description = "Enable or disable of the sqs"
}
variable "enable_redis" {
  type        = bool
  default     = false
  description = "Enable or disable of the redis"
}
variable "enable_apigatewayv2" {
  type        = bool
  default     = false
  description = "Enable or disable of the api_gateway"
}
variable "enable_apigateway" {
  type        = bool
  default     = false
  description = "Enable or disable of the api_gateway"
}
variable "create_apigatewayv2_api" {
  type        = bool
  default     = false
  description = "Enable or disable of the api_gateway"
}
variable "enable_vpc_link" {
  type        = bool
  default     = false
  description = "Enable or disable of the vpc_link"
}
variable "enable_vpc_endpoint" {
  type        = bool
  default     = false
  description = "Enable or disable of the vpc_endpoint"
}
variable "create_routes_and_integrations" {
  type        = bool
  default     = false
  description = "Enable or disable of the create_routes_and_integrations"
}
variable "create_default_stage" {
  type        = bool
  default     = false
  description = "Enable or disable of the create_default_stage"
}
variable "create_api_domain_name" {
  type        = bool
  default     = false
  description = "Enable or disable of the create_api_domain_name"
}
variable "create_default_stage_api_mapping" {
  type        = bool
  default     = false
  description = "Enable or disable of the create_default_stage_api_mapping"
}
variable "enable_scheduled_task" {
  type        = bool
  default     = false
  description = "Enable or disable of the scheduled_task"
}
variable "enable_apigateway_private" {
  type        = bool
  default     = false
  description = "Enable or disable of the apigateway_private"
}

# =======================================
#NETWORK
# =======================================

variable "vpc_id" {
  type        = string
  default     = ""
  description = "Vpc id for network module"
}
variable "mask_priv" {
  type        = list(string)
  default     = []
  description = <<EOF
  Mask for network module private
  ["0", "64", "128", "192"]
  EOF
}
variable "mask_pub" {
  type        = list(string)
  default     = []
  description = <<EOF
  Mask for network module public
  ["0", "64", "128", "192"]
  EOF
}
variable "cidr_priv" {
  type        = string
  default     = "10.11.13"
  description = "3 octetos available private"
}
variable "cidr_pub" {
  type        = string
  default     = "10.11.12"
  description = "3 octets available public"
}
variable "rt_pub" {
  type        = string
  default     = ""
  description = "Routing table id public"
}
variable "igw" {
  type        = string
  default     = null
  description = "IGW id available account"
}
variable "rt-priv-peering" {
  type = map(object({
    cidr_block                = string
    vpc_peering_connection_id = string
  }))
  default     = {}
  description = "Add peering rt private"
}
variable "rt-pub-peering" {
  type = map(object({
    cidr_block                = string
    vpc_peering_connection_id = string
  }))
  default     = {}
  description = "Add peering rt public"
}
variable "aws_vpn_gateway" {
  type        = string
  default     = null
  description = "Virtual private gateways id"
}
variable "route_propagation_priv" {
  type        = bool
  default     = false
  description = "Enable propagation rt private"
}
variable "route_propagation_pub" {
  type        = bool
  default     = false
  description = "Enable propagation rt public"
}


# #ROUTE53
# variable "aws_domain" {
#   default = null
# }

variable "route53_records" {
  type = map(any)
  default = {}
  description = "Add records custom"
}

# =======================================
#ALB
# =======================================

variable "config_alb" {
  type = map(object({
    deregistration_delay             = string
    target_type                      = string
    port                             = string
    protocol                         = string
    protocol_version                 = optional(string)
    health_check_path                = string
    health_check_port                = string
    health_check_protocol            = string
    health_check_healthy_threshold   = string
    health_check_unhealthy_threshold = string
    health_check_timeout             = string
    health_check_interval            = string
    health_check_matcher             = string
    conditions = list(object({
      field  = string
      values = list(string),
      })
    )
  }))
  default     = {}
  description = "Configuration target-group"
}

variable "config_nlb" {
  type = map(object({
    deregistration_delay             = string
    target_type                      = string
    port                             = string
    protocol                         = string
    protocol_version                 = optional(string)
    health_check_path                = optional(string)
    health_check_port                = string
    health_check_protocol            = string
    health_check_healthy_threshold   = string
    health_check_unhealthy_threshold = string
    health_check_timeout             = string
    health_check_interval            = string
    health_check_matcher             = optional(string)
  }))
  default     = {}
  description = "Configuration target-group"
}
variable "alpn_policy" {
  type    = string
  default = null
}
variable "alb_internal" {
  type        = bool
  default     = true
  description = "Enable and disable private load balance"
}
variable "bucket_log" {
  type        = string
  default     = ""
  description = "Name log bucket alb"
}
variable "aws_cert" {
  type        = string
  default     = ""
  description = "Certificate id for ALB"
}
variable "type_alb" {
  type        = string
  default     = ""
  description = "application (ALB) or network (NLB)"
}
variable "additional_certs" {
  type = list(string)
  default = []
  description = "List certificate adicional alb"
}

# =======================================
#SSM_PARAMETER and SECRET_MANAGER
# =======================================
variable "enable_secret_sync" {
  type        = bool
  default     = false
  description = "Enable sync vars terraform secretmanager"
}
variable "var_project" {
  type        = map(string)
  default     = {}
  description = "Variables managed only by secretmanager, non-sensitive values"
}
variable "AFRODITE_API_TOKEN" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "BIFROST_API_TOKEN" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "CHRONOS_API_KEY" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "CLIENT_SPACE_JWT_SECRET" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "CONFIGCAT_KEY" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "CRAVA_TOKEN" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "FIREBASE_API_TOKEN" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "FIREBASE_GOOGLE_APPLICATION_CREDENTIALS" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "FITNESS_CLASSES_TOKEN" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "NEW_RELIC_LICENSE_KEY" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "NUTRI_TOKEN" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "SECRET_KEY_BASE" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "SMARTFIT_SUPPS_JWE_SECRET_KEY" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "SMART_SITE_TOKEN" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "SMART_SYSTEM_V1_CLIENT_TOKEN" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "SMART_SYSTEM_V1_TOKEN" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "SMART_SYSTEM_V2_TOKEN" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "SMART_SYSTEM_V3_PERSON_KEY" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "SMART_SYSTEM_V3_TOKEN" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "TESEU_API_TOKEN" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "TOTAL_PASS_API_KEY" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "WORKOUT_TOKEN" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "DATABASE_URL" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "REDIS_URL" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "AWS_ACCESS_KEY_ID" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}
variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  default     = ""
  description = "secret in semaphoreci"
}

# =======================================
#SECURITY GROUP
# =======================================

variable "port_app" {
  type        = number
  default     = null
  description = "Port app ecs"
}
variable "port_rds" {
  type        = number
  default     = null
  description = "Port app rds"
}
variable "port_redis" {
  type        = number
  default     = null
  description = "Port app redis"
}
variable "port_apigateway" {
  type        = number
  default     = null
  description = "Port app apigateway"
}
variable "ingress_app" {
  type = map(object({
    from_port       = number,
    to_port         = number,
    protocol        = string,
    security_groups = optional(list(string)),
    cidr_blocks     = optional(list(string)),
    description     = string
  }))
  default     = {}
  description = "Add ips dynamic ecs"
}
variable "ingress_rds" {
  type = map(object({
    from_port       = number,
    to_port         = number,
    protocol        = string,
    security_groups = optional(list(string)),
    cidr_blocks     = optional(list(string)),
    description     = string
  }))
  default     = {}
  description = "Add ips dynamic rds"
}
variable "ingress_alb" {
  type = map(object({
    from_port       = number,
    to_port         = number,
    protocol        = string,
    security_groups = optional(list(string)),
    cidr_blocks     = optional(list(string)),
    description     = string
  }))
  default     = {}
  description = "Add ips dynamic alb"
}
variable "ingress_redis" {
  type = map(object({
    from_port       = number,
    to_port         = number,
    protocol        = string,
    security_groups = optional(list(string)),
    cidr_blocks     = optional(list(string)),
    description     = string
  }))
  default     = {}
  description = "Add ips dynamic redis"
}
variable "ingress_apigateway" {
  type = map(object({
    from_port       = number,
    to_port         = number,
    protocol        = string,
    security_groups = optional(list(string)),
    cidr_blocks     = optional(list(string)),
    description     = string
  }))
  default     = {}
  description = "Add ips dynamic ingress_apigateway"
}
variable "ingress_vpc_endpoint" {
  type = map(object({
    from_port       = number,
    to_port         = number,
    protocol        = string,
    security_groups = optional(list(string)),
    cidr_blocks     = optional(list(string)),
    description     = string
  }))
  default     = {}
  description = "Add ips dynamic ingress_vpc_endpoint"
}
# =======================================
#RDS
# =======================================

variable "config_rds" {
  type = map(object({
    cluster_instance_count = string,
    master_username        = string,
    database_name          = string,
    instance_class         = string,
    engine                 = string,
    engine_version         = string,
    engine_mode            = string
  }))
  default     = {}
  description = "Conguration for rds"
}

variable "password_rds" {
  type    = string
  default = ""
}

# =======================================
#ECS
# =======================================

variable "disable_deploy" {
  type        = bool
  default     = false
  description = "Enable and disable deploy"
}
variable "config_ecs" {
  type    = map(any)
  default = {}
}
variable "desired_count" {
  type        = string
  default     = "1"
  description = "Quantas tasks vai ter somente no momento da primeira montagem"
}
variable "env_app" {
  type        = string
  default     = "staging"
  description = "Environment do container"
}

# =======================================
# SCHEDULED-TASK
# =======================================

variable "config_ecs_scheduled_task" {
  type    = map(any)
  default = {}
}

# =======================================
# IAM
# =======================================

variable "iam_list" {
  type        = list(string)
  default     = []
  description = "O mesmo nome que esta nessa lista usuários, tem que estar no diretório policy com .json"
}

# =======================================
#ECS_AUTO_SCALING
# =======================================

variable "ecs_autoscaling_config" {
  type        = map(any)
  default     = {}
  description = <<EOF
ecs_autoscaling_config = {
  "name_service_ecs" = {
    cpu = {
        policy_type            = "TargetTrackingScaling",
        predefined_metric_type = "ECSServiceAverageCPUUtilization",
        target_value           = 60,
        scale_in_cooldown      = 15,
        scale_out_cooldown     = 300
      },
    alb = {
        policy_type            = "TargetTrackingScaling",
        predefined_metric_type = "ALBRequestCountPerTarget",
        resource_label         = "name_service_ecs"
        target_value           = 300,
        scale_in_cooldown      = 15,
        scale_out_cooldown     = 300
      }
      min_capacity = 1,
      max_capacity = 2,
  }
}
EOF
}

variable "rds_autoscaling_config" {
  type        = map(any)
  default     = {}
  description = <<EOF
rds_autoscaling_config = {
  "name_project" = {
    cpu = {
      policy_type            = "TargetTrackingScaling",
      predefined_metric_type = "RDSReaderAverageCPUUtilization",
      target_value           = 60,
      scale_in_cooldown      = 15,
      scale_out_cooldown     = 300,
    }
    min_capacity = 1,
    max_capacity = 5
  }
}
EOF
}


# =======================================
#ROUTE53
# =======================================

variable "aws_zoneid" {
  type        = string
  description = "Zone ID public"
  default     = ""
}
variable "aws_zoneid_private" {
  type        = string
  description = "Zone ID private"
  default     = ""
}
variable "enable_route53_private" {
  type        = bool
  description = "Enable e disable DNS private"
  default     = false
}

# =======================================
#ECR
# =======================================

variable "image_tag" {
  default = "latest"
}

# =======================================
#REDIS
# =======================================

variable "redis_list" {
  type        = map(any)
  default     = {}
  description = <<EOF
redis_list = {
  name_redis = {
    engine                     = "redis",
    type                       = "cache.t3.small",
    num_cache_clusters         = "1",
    replicas_per_node_group    = "0",
    parameter_group            = "default.redis7",
    engine_version             = "7.0",
    availability_zone          = ["us-east-1b"],
    automatic_failover_enabled = false
  }
}
EOF
}

# =======================================
#SQS
# =======================================

variable "filas-sqs" {
  type    = map(any)
  default = {}
}
variable "filas-sqs-deadletter" {
  type    = map(any)
  default = {}
}

# =======================================
#APIGATEWAYV2
# =======================================

variable "protocol_type" {
  description = "The API protocol. Valid values: HTTP, WEBSOCKET"
  type        = string
  default     = "HTTP"
}
variable "cors_configuration" {
  description = "The cross-origin resource sharing (CORS) configuration. Applicable for HTTP APIs."
  type        = any
  default     = {}
}
variable "integrations" {
  description = "Map of API gateway routes with integrations"
  type        = map(any)
  default     = {}
}
variable "authorizers" {
  description = "Map of API gateway authorizers"
  type        = map(any)
  default     = {}
}
variable "default_stage_access_log_format" {
  description = "Default stage's single line format of the access logs of data, as specified by selected $context variables."
  type        = string
  default     = null
}
variable "integration_uri" {
  description = "aws_lb_listener arn"
  type        = string
  default     = null
}
variable "default_route_settings" {
  description = "Settings for default route"
  type        = map(string)
  default     = {}
}
variable "mutual_tls_authentication" {
  description = "An Amazon S3 URL that specifies the truststore for mutual TLS authentication as well as version, keyed at uri and version"
  type        = map(string)
  default     = {}
}
variable "domain_name" {
  description = "The domain name to use for API gateway"
  type        = string
  default     = null
}
variable "path_stage_api_mapping" {
  description = "The stage_api_mapping to use for API gateway"
  type        = list(string)
  default     = []
}

# =======================================
#APIGATEWAY
# =======================================

variable "config_apigateway_private" {
  description = "Config for the API"
  type        = any
  default = {
    private = {
      # path_part   = "teste"
      types = "private",
      teste = {
        http_method = "POST"
      }
    }
  }
}
variable "openapi_config" {
  description = "The OpenAPI specification for the API"
  type        = any
  default     = {}
}

variable "create_aws_api_gateway_vpc_link" {
  type        = bool
  default     = false
  description = "enable resource"
}
variable "create_aws_api_gateway_deployment" {
  type        = bool
  default     = false
  description = "enable resource"
}
variable "create_aws_api_gateway_stage" {
  type        = bool
  default     = false
  description = "enable resource"
}
variable "create_aws_api_gateway_method_settings" {
  type        = bool
  default     = false
  description = "enable resource"
}
variable "create_aws_api_gateway_rest_api" {
  type        = bool
  default     = false
  description = "enable resource"
}

variable "config_apigateway" {
  type    = any
  default = {}
}
variable "apigateway_types" {
  type        = string
  default     = "PRIVATE"
  description = "PRIVATE, EDGE OR REGIONAL"
}
# =======================================
#WAF
# =======================================

 variable "enable_waf" {
  type        = bool
  default     = true
}
variable "enable_logging_waf" {
  type        = bool
  default     = true
}
variable "enable_associate_alb_waf" {
  type        = bool
  default     = true
}
variable "log_destination_arns_waf" {
  type        = string
  default     = ""
}


# =======================================
#VPC Endpoint
# =======================================
variable "endpoints" {
  description = "A map of interface and/or gateway endpoints containing their properties and configurations"
  type        = any
  default     = {}
}

variable "timeouts" {
  description = "Define maximum timeout for creating, updating, and deleting VPC endpoint resources"
  type        = map(string)
  default     = {}
}

# =======================================
#S3
# =======================================
variable "sync_source_role_s3" {
  default = null
}
variable "bunckets" {
  type = map(any)
  default = {
    bucket_name = { block_public_acls = "true", block_public_policy = "true", ignore_public_acls = "true", restrict_public_buckets = "true", acl = "private", status = "Enabled" }
  }
}
variable "cors_config" {
  type = map(any)
  default = {
    bucket_name = { allowed_headers = "", allowed_methods = "", allowed_origins = "", expose_headers = "", max_age_seconds = "" }
  }
}
variable "enable_cors" {
  default = false
}

variable "enable_s3" {
  default = "false"
}

variable "enable_sync_s3" {
  default = "false"
}

variable "enable_static" {
  default = "false"
}

variable "aws_account_id_source" {
  default = null
}

#=======================================
#CLOUDFRONT
#=======================================

variable "enable_cloudfront" {
  default = "false"
}

variable "cloufront_config_alb" {
  type    = map(any)
  default = {}
}

