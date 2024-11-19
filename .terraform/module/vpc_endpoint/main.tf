################################################################################
# Endpoint(s)
################################################################################

resource "aws_vpc_endpoint" "this" {
  for_each = var.endpoints

  vpc_id            = var.vpc_id
  service_name      = each.value.service_name
  vpc_endpoint_type = try(each.value.service_type, "Interface")
  auto_accept       = try(each.value.auto_accept, null)

  security_group_ids  = try(each.value.service_type, "Interface") == "Interface" ? try(var.security_group_ids, null) : null
  subnet_ids          = try(each.value.service_type, "Interface") == "Interface" ? try(var.subnet_ids, null) : null
  route_table_ids     = try(each.value.service_type, "Interface") == "Gateway" ? try(var.route_table_ids, null) : null
  policy              = try(each.value.policy, null)
  private_dns_enabled = try(each.value.service_type, "Interface") == "Interface" ? try(each.value.private_dns_enabled, null) : null

  tags = merge(var.tags, {
    Name = "${var.aws_project}-${each.key}-${var.aws_env}"
  })

  timeouts {
    create = try(var.timeouts.create, "10m")
    update = try(var.timeouts.update, "10m")
    delete = try(var.timeouts.delete, "10m")
  }
}
