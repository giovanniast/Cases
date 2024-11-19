#PROJECT
aws_profile     = "prod"
aws_project     = "order-book"
aws_prefix      = "mercado-livre"
aws_region      = "us-east-1"
aws_env         = "production"
aws_account_id  = "00000000000"

tag_project = {
  APP       = "order-book"
  DPT       = "engineering"
  ENV       = "production"
  IAC       = "terraform"
  Terraform = "enable"
}

#VPC
vpc_id = "vpc-00000000000000000"
rt_pub = "rtb-00000000000000000"

#ROUTE TABLE
route_propagation_pub  = "false"
route_propagation_priv = "true"
aws_vpn_gateway        = "vgw-00000000000000000"

#SUBNET
enable_network = true
cidr_priv      = "10.x.x"
cidr_pub       = "10.x.x"
mask_priv = ["0", "64", "128"]
mask_pub  = ["0", "64", "128"]

#IAM - lembrar de revisar a politica
enable_iam = true
iam_list = [
  "sys_order-book"
]

#SECRET_MANAGER
enable_secretmanager = true
enable_secret_sync   = true
#VARs
var_project = {
  VARIAVEIS = "XPTO"
}

#SECURITY GROUP
enable_security-group = true
port_app              = 3000
port_rds              = 5432
port_redis            = 6379
ingress_alb = {
  https = {
    from_port   = 443,
    to_port     = 443,
    protocol    = "tcp",
    cidr_blocks = ["0.0.0.0/0"],
    description = "HTTPS"
  }
  http = {
    from_port   = 80,
    to_port     = 80,
    protocol    = "tcp",
    cidr_blocks = ["0.0.0.0/0"],
    description = "HTTP"
  }
}

#ALB/NLB
enable_alb   = true
alb_internal = false
type_alb     = "application"
aws_cert     = "xxxxxxxxx" #arn do certificado
config_alb = {
  "api" = {
    #target_group
    deregistration_delay = "100"
    target_type          = "ip"
    port                 = "3000"
    protocol             = "HTTP"
    # protocol_version     = "HTTP"
    #health_check
    health_check_path                = "/health_check"
    health_check_protocol            = "HTTP"
    health_check_port                = "3000"
    health_check_healthy_threshold   = "4"
    health_check_unhealthy_threshold = "6"
    health_check_timeout             = "15"
    health_check_interval            = "20"
    health_check_matcher             = "200"
    #listener_rules
    conditions = [
      {
        field  = "host_header",
        values = ["orderbook.com.br"],
      },
      {
        field  = "path_pattern",
        values = ["/*"],
      }
    ]
  }
}

config_nlb = {
  "app" = {
    #target_group
    deregistration_delay = "100"
    target_type          = "ip"
    port                 = "3000"
    protocol             = "TCP"
    #health_check
    health_check_protocol            = "TCP"
    health_check_port                = "3000"
    health_check_healthy_threshold   = "4"
    health_check_unhealthy_threshold = "6"
    health_check_timeout             = "15"
    health_check_interval            = "20"
  }
}

#RDS #criar instancia de leitura na mão se for preciso
enable_rds = true
config_rds = {
  order-book = {
    cluster_instance_count = "1",
    master_username        = "postgres",
    database_name          = "orderbook",
    instance_class         = "db.r6g.large",
    engine                 = "aurora-postgresql",
    engine_version         = "13.12",
    engine_mode            = "provisioned"
  }
}

#ECS
enable_ecs = true
config_ecs = {
  "api" = {
    cpu                  = "4096", #c5a.large em produção
    memory               = "8192",
    health_check_grace   = "60",
    target_group_arn     = true
    target_group_nlb_arn = true
    command              = ["bundle", "exec", "rails", "server", "--port=3000"] #dev passará os comandos corretos
  }
  "sqs" = {
    cpu                  = "2048", #t3.medium em produção
    memory               = "4096",
    health_check_grace   = "60"
    target_group_arn     = false
    target_group_nlb_arn = false
    command              = ["bundle", "exec", "shoryuken"] #dev passará os comandos corretos
  }
}
env_app = "production"

#AUTO_SCALING_ECS
enable_autoscaling_ecs = true
ecs_autoscaling_config = {
  "app" = {
    cpu = {
      policy_type            = "TargetTrackingScaling",
      predefined_metric_type = "ECSServiceAverageCPUUtilization",
      target_value           = 70,
      scale_in_cooldown      = 15,
      scale_out_cooldown     = 300
    }
    alb = {
      policy_type            = "TargetTrackingScaling",
      predefined_metric_type = "ALBRequestCountPerTarget",
      resource_label         = "api"
      target_value           = 1500,
      scale_in_cooldown      = 15,
      scale_out_cooldown     = 300
    }
    min_capacity = 7,
    max_capacity = 20,
  }
}

#AUTO_SCALING_RDS
enable_autoscaling_rds = false
rds_autoscaling_config = {
  "order-book" = {
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

#ROUTE53
enable_route53         = true
enable_route53_private = false
aws_zoneid             = "XXXXXXXXXXXXXX"
aws_zoneid_private     = "XXXXXXXXXXXXXX"

#CLOUDWATCH
enable_cloudwatch = true

#ECR
enable_ecr = true

#REDIS
enable_redis = true
redis_list = {
  order-book = {
    engine                     = "redis",
    type                       = "cache.m5.large",
    num_cache_clusters         = "1",
    replicas_per_node_group    = "0",
    parameter_group            = "default.redis7",
    engine_version             = "7.1",
    availability_zone          = ["us-east-1b"],
    automatic_failover_enabled = false
  }
}

#SQS
enable_sqs = true
filas-sqs = {
  order_book_production = {
    delay_seconds              = null,
    max_message_size           = "262144",
    message_retention_seconds  = "345600",
    receive_wait_time_seconds  = null,
    visibility_timeout_seconds = "5",
    deadletter                 = "order_book_production_deadletter_production",
    fifo_queue                 = "false"
  }
}
filas-sqs-deadletter = {
  order_book_production_deadletter_production = {
    sqs                        = "order_book_production",
    message_retention_seconds  = "345600",
    visibility_timeout_seconds = "30",
    fifo_queue                 = "false"
  }
}

#S3 (para logs e/ou backups)
enable_s3           = "true"
bunckets = {
  order-book-production = {
    block_public_acls       = "true",
    block_public_policy     = "true",
    ignore_public_acls      = "true",
    restrict_public_buckets = "true",
    acl                     = "private",
    status                  = "Enabled",
    enable_static           = "false" 
  }
}

enable_waf = true
log_destination_arns_waf = "arn:aws:s3:::order-book-production"

#CLOUDFRONT
cloufront_config_alb = {
  order-book-production-alb = {
    domain_name         = ["orderbook.com.br"]
    comment             = "orderbook.com.br"
    default_root_object = "/"
    price_class         = "PriceClass_100"
    allowed_methods     = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods      = ["GET", "HEAD", "OPTIONS"]
    type                = "alb"
  }
}