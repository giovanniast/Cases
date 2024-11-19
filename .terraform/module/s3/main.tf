resource "aws_s3_bucket" "main" {
  for_each      = var.bunckets
  bucket        = each.key
  tags          = var.tag_project
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "example" {
  for_each = var.bunckets
  bucket   = aws_s3_bucket.main[each.key].id

  rule {
    object_ownership = each.value.enable_static == "true" ? "BucketOwnerPreferred" : "BucketOwnerEnforced"
  }
}

data "template_file" "s3" {
  for_each = var.bunckets
  template = file("${path.root}/policy/s3/${each.key}.json")
  vars = {
    bucket                = "${aws_s3_bucket.main[each.key].arn}"
    aws_account_id        = "${var.aws_account_id}"
    aws_account_id_source = "${var.aws_account_id_source}"
    sync_source_role_s3   = "${var.sync_source_role_s3}"
    cloudfront            = "${var.cloufront_id}"
  }
}

resource "aws_s3_bucket_policy" "app" {
  for_each = var.bunckets
  bucket   = aws_s3_bucket.main[each.key].id
  policy   = data.template_file.s3[each.key].rendered
}


resource "aws_s3_bucket_versioning" "main" {
  for_each = var.bunckets
  bucket   = aws_s3_bucket.main[each.key].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  for_each = var.bunckets
  bucket   = aws_s3_bucket.main[each.key].id

  block_public_acls       = each.value.block_public_acls
  block_public_policy     = each.value.block_public_policy
  ignore_public_acls      = each.value.ignore_public_acls
  restrict_public_buckets = each.value.restrict_public_buckets
}

