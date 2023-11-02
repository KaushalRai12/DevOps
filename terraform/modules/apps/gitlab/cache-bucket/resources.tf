#============= Caching in S3
resource aws_s3_bucket bucket {
	bucket = var.bucket_name
}

resource aws_s3_bucket_acl bucket {
	bucket = aws_s3_bucket.bucket.id
	acl = "private"
}

resource aws_s3_bucket_public_access_block bucket_access_block {
	bucket = aws_s3_bucket.bucket.id

	block_public_acls = true
	block_public_policy = true
	ignore_public_acls = true
	restrict_public_buckets = true
}

resource aws_iam_policy bucket_policy {
	name = "aex-gitlab"
	policy = data.template_file.s3_bucket_policy.rendered
}

resource aws_iam_user_policy_attachment bucket_user_policy {
	user = "gitlab"
	policy_arn = aws_iam_policy.bucket_policy.arn
}
