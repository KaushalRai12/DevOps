#TODO: Add bucket specific policy setting for future applications that relies on S3

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.org_prefix}-${var.base_name}-${var.env}"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = var.public_acl_policy.block_public_acls
  block_public_policy     = var.public_acl_policy.block_public_policy
  ignore_public_acls      = var.public_acl_policy.ignore_public_acls
  restrict_public_buckets = var.public_acl_policy.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_config" {
  count  = var.enable_encryption ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
    }
  }
}