data "aws_availability_zones" "available" {}

resource "aws_subnet" "subnets_priv" {
  count                   = length(var.mask_priv)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = var.vpc_id
  cidr_block              = "${var.cidr_priv}.${var.mask_priv[count.index]}/26"
  map_public_ip_on_launch = true
  tags = merge(
    var.tag_project,
    {
      Name = "${var.aws_prefix}-${var.aws_project}-subnet-priv-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}

resource "aws_subnet" "subnets_pub" {
  count                   = length(var.mask_pub)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  vpc_id                  = var.vpc_id
  cidr_block              = "${var.cidr_pub}.${var.mask_pub[count.index]}/26"
  map_public_ip_on_launch = true
  tags = merge(
    var.tag_project,
    {
      Name = "${var.aws_prefix}-${var.aws_project}-subnet-pub-${data.aws_availability_zones.available.names[count.index]}"
    }
  )
}

resource "aws_route_table_association" "public" {
  count          = length(var.mask_pub)
  subnet_id      = aws_subnet.subnets_pub[count.index].id
  route_table_id = var.rt_pub == null ? aws_route_table.rt_pub[0].id : var.rt_pub
  depends_on = [
    aws_route_table.rt_pub
  ]
}

resource "aws_route_table_association" "priv" {
  count          = length(var.mask_priv)
  subnet_id      = aws_subnet.subnets_priv[count.index].id
  route_table_id = aws_route_table.rt_priv.id
  depends_on = [
    aws_route_table.rt_priv
  ]
}

#REDIS
resource "aws_elasticache_subnet_group" "main_redis" {
  count      = var.enable_redis ? 1 : 0
  name       = "${var.aws_prefix}-${var.aws_project}-${var.aws_env}"
  subnet_ids = aws_subnet.subnets_priv[*].id
  tags = merge(var.tag_project,
    {
      Name = "${var.aws_prefix}-${var.aws_project}_subnet_priv"
    }
  )
}

#RDS
resource "aws_db_subnet_group" "main_rds" {
  for_each   = var.enable_rds ? var.config_rds : {}
  name       = "${var.aws_prefix}-${each.key}-${var.aws_env}"
  subnet_ids = aws_subnet.subnets_priv[*].id
  tags = merge(var.tag_project,
    {
      Name = "${var.aws_prefix}-${each.key}_subnet_priv"
    }
  )
}

#EIP
resource "aws_eip" "main" {
  vpc = true
  tags = merge(
    var.tag_project,
    {
      Name = "${var.aws_prefix}-${var.aws_project}-nat"
    }
  )
  # lifecycle {
  #   prevent_destroy = true
  # }
}

#NAT
resource "aws_nat_gateway" "main" {

  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.subnets_pub[0].id

  tags = merge(
    var.tag_project,
    {
      Name = "${var.aws_prefix}-${var.aws_project}-nat"
    }
  )
  depends_on = [
    aws_subnet.subnets_pub,
    aws_eip.main
  ]
}

#ROUTE TABLE PRIVATE
resource "aws_route_table" "rt_priv" {
  vpc_id = var.vpc_id
  tags = merge(
    var.tag_project,
    {
      Name = "rt-${var.aws_prefix}-${var.aws_project}-priv"
    }
  )
  dynamic "route" {
    for_each = var.rt-priv-peering
    content {
      cidr_block                = route.value.cidr_block
      vpc_peering_connection_id = route.value.vpc_peering_connection_id
    }
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  depends_on = [aws_nat_gateway.main]
}

#ROUTE TABLE PUBLICO PARA TODOS OS SYSTEMAS
resource "aws_route_table" "rt_pub" {
  count  = var.rt_pub == null ? 1 : 0
  vpc_id = var.vpc_id
  tags = merge(
    var.tag_project,
    {
      Name = "rt-${var.aws_prefix}-${var.aws_project}-public"
    }
  )
  dynamic "route" {
    for_each = var.rt-pub-peering
    content {
      cidr_block                = route.value.cidr_block
      vpc_peering_connection_id = route.value.vpc_peering_connection_id
    }
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw
  }
}

resource "aws_vpn_gateway_route_propagation" "priv" {
  count          = var.route_propagation_priv && var.aws_vpn_gateway != null ? 1 : 0
  vpn_gateway_id = var.aws_vpn_gateway
  route_table_id = aws_route_table.rt_priv.id
}

resource "aws_vpn_gateway_route_propagation" "pub" {
  count          = var.route_propagation_pub && var.aws_vpn_gateway != null ? 1 : 0
  vpn_gateway_id = var.aws_vpn_gateway
  route_table_id = try(aws_route_table.rt_pub[0].id, try(var.rt_pub, null))
}
