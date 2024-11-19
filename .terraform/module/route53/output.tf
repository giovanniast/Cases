output "fqdn" {
  value = var.aws_env == "production" ? [ for k,v in aws_route53_record.prod : v.fqdn ] : [ aws_route53_record.main-stg[0].fqdn ]
}
