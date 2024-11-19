variable "bunckets" {
  type = map(any)
  default = {
    "bucket_name" = { block_public_acls = "true", block_public_policy = "true", ignore_public_acls = "true", restrict_public_buckets = "true", acl = "private", status = "Enabled" }
  }
}
variable "tag_project" {}
variable "aws_project" {}
variable "aws_account_id" {}
variable "aws_account_id_source" {}
