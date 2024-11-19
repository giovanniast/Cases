resource "aws_route53_record" "main" {
  count   = var.aws_env == "production" ? 1 : 0
  zone_id = var.aws_zoneid
  provider = aws.aws
  name    = "orderbook" //var.aws_project
  type    = "CNAME"
  ttl     = 300
  records = [var.alias_name]
}

resource "aws_route53_record" "prod" {
  for_each  = var.aws_env == "production" ? var.route53_records : {}
  provider  = aws.aws
  zone_id   = each.value.zone_id
  name      = each.value.name
  type      = each.value.type
  ttl       = each.value.ttl
  records   = [try(each.value.records,var.alias_name)]
}