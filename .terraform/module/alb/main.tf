resource "aws_lb" "main" {
  name                             = var.type_alb == "application" ? "alb-${var.aws_prefix}-${var.aws_project}-${var.random_value}" : "nlb-${var.aws_prefix}-${var.aws_project}-${var.random_value}"
  internal                         = var.alb_internal
  load_balancer_type               = var.type_alb
  security_groups                  = var.security_groups
  subnets                          = var.alb_internal ? var.subnet_priv : var.subnet_pub
  enable_cross_zone_load_balancing = var.type_alb == "network" ? true : null

    access_logs {
      bucket  = var.bucket_log
      prefix  = var.type_alb == "application" ? "alb-${var.aws_prefix}-${var.aws_project}-${var.random_value}" : "nlb-${var.aws_prefix}-${var.aws_project}-${var.random_value}"
      enabled = true
    }
    enable_deletion_protection = true
    tags                       = var.tag_project
}

resource "aws_lb_target_group" "main" {
  for_each             = var.config_alb
  name_prefix          = var.random_value
  port                 = each.value.port
  protocol             = each.value.protocol
  target_type          = each.value.target_type
  vpc_id               = var.vpc_id
  deregistration_delay = each.value.deregistration_delay
  protocol_version     = try(each.value.protocol_version, null)

  health_check {
    path                = each.value.health_check_path
    port                = each.value.health_check_port
    protocol            = each.value.health_check_protocol
    healthy_threshold   = each.value.health_check_healthy_threshold
    unhealthy_threshold = each.value.health_check_unhealthy_threshold
    timeout             = each.value.health_check_timeout
    interval            = each.value.health_check_interval
    matcher             = each.value.health_check_matcher # has to be HTTP 200 or fails
  }
  lifecycle {
    create_before_destroy = true
  }

  tags = var.tag_project
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
  depends_on = [
    aws_lb_target_group.main,
    aws_lb_listener.https
  ]

  tags = var.tag_project
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10" //"ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.aws_cert

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Essa rota não existe."
      status_code  = "200"
    }
  }
  # default_action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.main[each.key].arn
  # }
  tags       = var.tag_project
  depends_on = [aws_lb_target_group.main]
}

resource "aws_lb_listener_certificate" "https_additional_certs" {
  count           = length(var.additional_certs)
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = var.additional_certs[count.index]
}

resource "aws_lb_listener_rule" "main" {
  for_each     = var.config_alb
  listener_arn = aws_lb_listener.https.arn
  # priority     = one(distinct([ for k,v in var.config_alb : one(distinct([ for x,y in v.conditions: x ])) ]))
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[each.key].arn
  }
  tags = merge(
    {
      Name = each.key
    },
  var.tag_project)

  dynamic "condition" {
    for_each = each.value.conditions
    content {
      dynamic "path_pattern" {
        for_each = { for k, v in each.value.conditions : k => v if v.field == "path_pattern" }
        content {
          values = try(path_pattern.value.values, null)
        }
      }
    }
  }

  dynamic "condition" {
    for_each = each.value.conditions
    content {
      dynamic "host_header" {
        for_each = { for k, v in each.value.conditions : k => v if v.field == "host_header" }
        content {
          values = try(host_header.value.values, null)
        }
      }
    }
  }

}

#ALB APIGATEWAY
resource "aws_lb" "apigateway" {
  count                            = var.enable_apigateway_private ? 1 : 0
  name                             = "nlb-${var.aws_prefix}-${var.aws_project}-${var.random_value}"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = var.subnet_priv
  enable_cross_zone_load_balancing = true

  access_logs {
    bucket  = var.bucket_log
    prefix  = "nlb-${var.aws_prefix}-${var.aws_project}-${var.random_value}"
    enabled = true
  }

  tags = var.tag_project
}

resource "aws_lb_target_group" "apigateway" {
  for_each             = var.config_nlb
  name_prefix          = var.random_value
  port                 = each.value.port
  protocol             = each.value.protocol
  target_type          = each.value.target_type
  vpc_id               = var.vpc_id
  deregistration_delay = each.value.deregistration_delay
  protocol_version     = try(each.value.protocol_version, null)

  health_check {
    path                = try(each.value.health_check_path,null)
    port                = each.value.health_check_port
    protocol            = each.value.health_check_protocol
    healthy_threshold   = each.value.health_check_healthy_threshold
    unhealthy_threshold = each.value.health_check_unhealthy_threshold
    timeout             = each.value.health_check_timeout
    interval            = each.value.health_check_interval
    matcher             = try(each.value.health_check_matcher,null)
  }
  lifecycle {
    create_before_destroy = true
  }

  tags = var.tag_project
}

resource "aws_lb_listener" "apigateway-https" {
  for_each          = var.config_nlb
  load_balancer_arn = aws_lb.apigateway[0].arn
  port              = "443"
  protocol          = "TLS"
  ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
  alpn_policy       = try(var.alpn_policy, "None")
  certificate_arn   = var.aws_cert

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apigateway[each.key].arn
  }
  tags       = var.tag_project
  depends_on = [aws_lb_target_group.apigateway]
}
