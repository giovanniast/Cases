output "bucket" {
  value = [for v in aws_s3_bucket.main : v.bucket]
}
