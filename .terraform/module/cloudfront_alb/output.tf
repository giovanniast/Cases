output "id" {
  value = [for v in aws_cloudfront_distribution.main : v.id]
}
output "arn" {
  value = [for v in aws_cloudfront_distribution.main : v.arn]
}
output "iam-arn" {
  value = [for v in aws_cloudfront_origin_access_identity.main : v.iam_arn]
}
output "hosted_zone_id" {
  value = [for v in aws_cloudfront_distribution.main : v.hosted_zone_id]
}
output "domain_name" {
  value = [for v in aws_cloudfront_distribution.main : v.domain_name]
}