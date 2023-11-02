resource aws_s3_bucket bucket {
	bucket = local.bucket_name
}

resource aws_s3_bucket_acl db {
	bucket = aws_s3_bucket.bucket.id
	acl    = "private"
}

resource aws_s3_bucket_server_side_encryption_configuration db {
	bucket = aws_s3_bucket.bucket.bucket
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "aws:kms"
		}
	}
}

resource aws_s3_bucket_versioning lb_logs {
	bucket = aws_s3_bucket.bucket.id
	versioning_configuration {
		status = "Enabled"
	}
}

resource aws_s3_bucket_public_access_block bucket_access_block {
	bucket = aws_s3_bucket.bucket.id

	block_public_acls = true
	block_public_policy = true
	ignore_public_acls = true
	restrict_public_buckets = true
}

data aws_iam_policy_document policy {
	statement {
		actions = [
			"s3:ListBucket",
			"s3:GetBucketLocation",
			"s3:ListBucketMultipartUploads"
		]

		effect = "Allow"

		resources = ["arn:aws:s3:::${local.bucket_name}"]
	}

	statement {
		actions = [
			"s3:PutObject",
			"s3:GetObject",
			"s3:DeleteObject",
			"s3:ListMultipartUploadParts",
			"s3:AbortMultipartUpload"
		]

		effect = "Allow"

		resources = ["arn:aws:s3:::${local.bucket_name}/*"]
	}
}

resource aws_iam_policy bucket_policy {
	name = local.bucket_name
	policy = data.aws_iam_policy_document.policy.json
}

resource aws_iam_user system_artifact_db {
	name = "system-artifact-db${local.suffix}"
}

resource aws_iam_user_policy_attachment bucket_user_policy {
	user = aws_iam_user.system_artifact_db.name
	policy_arn = aws_iam_policy.bucket_policy.arn
}
