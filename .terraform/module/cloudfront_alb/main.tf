resource "aws_cloudfront_origin_access_identity" "main" {
  for_each = var.cloufront_config
  comment  = each.value.comment
}

resource "aws_cloudfront_distribution" "main" {
  for_each            = var.cloufront_config
  enabled             = true
  comment             = " ${each.key} in ${each.value.type}"
  default_root_object = each.value.default_root_object
  aliases             = each.value.domain_name
  # web_acl_id          = var.web_acl_id
  default_cache_behavior {
    target_origin_id           = "${each.key}-origin"
    allowed_methods            = each.value.allowed_methods
    cached_methods             = each.value.cached_methods
    viewer_protocol_policy     = "redirect-to-https"
    forwarded_values {
      headers      = ["Host","Authorization"]
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }


  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  tags = var.tag_project

  viewer_certificate {
    acm_certificate_arn      = var.aws_cert
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  price_class = each.value.price_class

  origin {
    origin_id   = "${each.key}-origin"
    domain_name = var.alb_dns_name
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # logging_config {
  #   include_cookies = false
  #   bucket          = var.bucket_log
  #   prefix          = "cloutfront-${var.aws_project}-${var.aws_env}"
  # }
}