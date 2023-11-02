resource aws_iam_user thumbtribe_user {
  name = "thumbtribe-user"
}

resource aws_iam_access_key thumbtribe_access_key {
  user = aws_iam_user.thumbtribe_user.name
}

resource aws_s3_bucket thumbtribe_bucket {
	bucket = "${var.org_prefix}-thumbtribe-${var.env}"
}

resource aws_s3_bucket_public_access_block thumbtribe_bucket_block_public {
	bucket = aws_s3_bucket.thumbtribe_bucket.id
	block_public_acls = true
	block_public_policy = true
	ignore_public_acls = true
	restrict_public_buckets = true
}


data aws_iam_policy_document thumbtribe_bucket_policy {
	statement {
		effect = "Allow"
		actions = [
			"s3:PutObject"
		]
		resources = ["${aws_s3_bucket.thumbtribe_bucket.arn}/*"]
	}
}


resource aws_iam_policy thumbtribe_policy {
  name        = "ThumbtribeS3Access"
  description = "Allows Thumbtribe user to access the S3 bucket"
  policy      = data.aws_iam_policy_document.thumbtribe_bucket_policy.json
}

resource aws_iam_user_policy_attachment thumbtribe_attachment {
  user       = aws_iam_user.thumbtribe_user.name
  policy_arn = aws_iam_policy.thumbtribe_policy.arn
}

resource aws_secretsmanager_secret thumbtribe_secret {
  name = "ThumbtribeAccessKeys"
}

resource aws_secretsmanager_secret_version thumbtribe_secret_version {
  secret_id     = aws_secretsmanager_secret.thumbtribe_secret.id
  secret_string = jsonencode({
    access_key_id     = aws_iam_access_key.thumbtribe_access_key.id,
    secret_access_key = aws_iam_access_key.thumbtribe_access_key.secret
  })
}