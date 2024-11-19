resource "aws_security_group" "alb" {
  count       = var.enable_alb ? 1 : 0
  name_prefix = "${var.aws_project}-alb"
  description = "Allow inbound Web only"
  vpc_id      = var.vpc_id
  tags = merge(var.tag_project,
    {
      Name = "${var.aws_prefix}-${var.aws_project}-alb"
    }
  )

  dynamic "ingress" {
    for_each = var.ingress_alb
    content {
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "All"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "app" {
  name_prefix = "${var.aws_project}-app"
  description = "Allow inbound Web only"
  vpc_id      = var.vpc_id
  tags = merge(var.tag_project,
    {
      Name = "${var.aws_prefix}-${var.aws_project}-app"
    }
  )
  ingress {
    protocol        = "tcp"
    from_port       = var.port_app
    to_port         = var.port_app
    security_groups = [try(aws_security_group.alb[0].id, null)]
    description     = "enable ${try(aws_security_group.alb[0].name, "")}"
  }

  ingress {
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [try(aws_security_group.alb[0].id, null)]
    description     = "enable ${try(aws_security_group.alb[0].name, "")}"
  }

  dynamic "ingress" {
    for_each = var.ingress_app
    content {
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "All"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "rds" {
  count       = var.enable_rds ? 1 : 0
  name_prefix = "${var.aws_project}-rds"
  description = "Allow inbound Web only"
  vpc_id      = var.vpc_id
  tags = merge(var.tag_project,
    {
      Name = "${var.aws_prefix}-${var.aws_project}-rds"
    }
  )

  ingress {
    protocol        = "tcp"
    from_port       = var.port_rds
    to_port         = var.port_rds
    security_groups = [aws_security_group.app.id]
    description     = "enable ${aws_security_group.app.name}"
  }

  dynamic "ingress" {
    for_each = var.ingress_rds
    content {
      protocol        = ingress.value.protocol
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.security_groups
      description     = ingress.value.description
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "All"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "redis" {
  count       = var.enable_redis ? 1 : 0
  name_prefix = "${var.aws_project}-redis"
  description = "Allow inbound Web only"
  vpc_id      = var.vpc_id
  tags = merge(var.tag_project,
    {
      Name = "${var.aws_prefix}-${var.aws_project}-redis"
    }
  )

  ingress {
    protocol        = "tcp"
    from_port       = var.port_redis
    to_port         = var.port_redis
    security_groups = [aws_security_group.app.id]
    description     = "enable ${aws_security_group.app.name}"
  }

  dynamic "ingress" {
    for_each = var.ingress_redis
    content {
      protocol        = ingress.value.protocol
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      security_groups = ingress.value.security_groups
      description     = ingress.value.description
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "All"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "apigatewayv2" {
  count       = var.enable_apigatewayv2 && var.enable_vpc_link ? 1 : 0
  name_prefix = "${var.aws_project}-apigateway"
  description = "Allow inbound Web only"
  vpc_id      = var.vpc_id
  tags = merge(var.tag_project,
    {
      Name = "${var.aws_prefix}-${var.aws_project}-apigateway"
    }
  )

  ingress {
    protocol        = "tcp"
    from_port       = var.port_apigateway
    to_port         = var.port_apigateway
    security_groups = [aws_security_group.app.id]
    description     = "enable ${aws_security_group.app.name}"
  }

  dynamic "ingress" {
    for_each = var.ingress_apigateway
    content {
      protocol        = ingress.value.protocol
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      security_groups = ingress.value.security_groups
      description     = ingress.value.description
    }
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "All"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_security_group" "vpc_endpoint" {
  count       = var.enable_vpc_endpoint ? 1 : 0
  name_prefix = "${var.aws_project}-vpc_endpoint"
  description = "Allow inbound Web only"
  vpc_id      = var.vpc_id
  tags = merge(var.tag_project,
    {
      Name = "${var.aws_prefix}-${var.aws_project}-vpc_endpoint"
    }
  )

  dynamic "ingress" {
    for_each = var.ingress_vpc_endpoint
    content {
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  lifecycle {
    create_before_destroy = true
  }
}
