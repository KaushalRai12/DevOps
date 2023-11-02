resource aws_s3_bucket state {
	bucket = "vumatel-tf-state"
}

/*
resource aws_s3_bucket_server_side_encryption_configuration lb_logs {
	bucket = aws_s3_bucket.state.bucket
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "aws:kms"
		}
	}
}
*/

resource aws_s3_bucket_replication_configuration state {
  depends_on = [aws_s3_bucket_versioning.state]
	bucket = aws_s3_bucket.state.id
	role = aws_iam_role.replication.arn

	rule {
		id = "backup-tf-state"
		status = "Enabled"

		destination {
			bucket = aws_s3_bucket.backup.arn
			storage_class = "STANDARD"
		}
	}
}

resource aws_s3_bucket_acl state {
	bucket = aws_s3_bucket.state.id
	acl = "private"
}

resource aws_s3_bucket_lifecycle_configuration expiration {
	bucket = aws_s3_bucket.state.bucket

	rule {
		id = "expire-old-versions"
		status = "Enabled"
		noncurrent_version_expiration {
			noncurrent_days = 90
		}
	}
}

resource aws_s3_bucket_server_side_encryption_configuration state {
	bucket = aws_s3_bucket.state.bucket
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "aws:kms"
		}
	}
}

resource aws_s3_bucket_versioning state {
	bucket = aws_s3_bucket.state.id
	versioning_configuration {
		status = "Enabled"
	}
}

resource aws_s3_bucket_public_access_block state {
	bucket = aws_s3_bucket.state.id

	block_public_acls = true
	block_public_policy = true
	ignore_public_acls = true
	restrict_public_buckets = true
}

resource aws_dynamodb_table lock {
	name = "tf-state-lock"
	hash_key = local.lock_key_id
	billing_mode = "PAY_PER_REQUEST"

	attribute {
		name = local.lock_key_id
		type = "S"
	}
}

resource aws_iam_policy terraform {
	name = "vumatel-terraform"
	policy = data.template_file.s3_bucket_policy.rendered
}

resource aws_iam_group devops {
	name = "DevOps"
}
resource aws_iam_group_policy_attachment remote_state_access {
	group = aws_iam_group.devops.name
	policy_arn = aws_iam_policy.terraform.arn
}

resource aws_s3_bucket backup {
	provider = aws.eu
	bucket = "vumatel-tf-state-backup"

	lifecycle {
		prevent_destroy = false
	}
}

resource aws_s3_bucket_acl backup {
	provider = aws.eu
	bucket = aws_s3_bucket.backup.id
	acl = "private"
}

resource aws_s3_bucket_versioning backup {
	provider = aws.eu
	bucket = aws_s3_bucket.backup.id
	versioning_configuration {
		status = "Enabled"
	}
}

resource aws_s3_bucket_lifecycle_configuration backup_expiration {
	provider = aws.eu
	bucket = aws_s3_bucket.backup.bucket

	rule {
		id = "expire-old-versions"
		status = "Enabled"
		noncurrent_version_expiration {
			noncurrent_days = 180
		}
	}
}

resource aws_s3_bucket_public_access_block backup {
	bucket = aws_s3_bucket.backup.id
	provider = aws.eu

	block_public_acls = true
	block_public_policy = true
	ignore_public_acls = true
	restrict_public_buckets = true
}

resource aws_iam_role replication {
	name_prefix = "replication"
	description = "Allow S3 to assume the role for replication"

	assume_role_policy = file("${path.module}/templates/replication-role-policy.json")
}

resource aws_iam_policy replication {
	name_prefix = "replication"
	description = "Allows reading for replication."

	policy = data.template_file.replication_policy.rendered
}

resource aws_iam_policy_attachment replication_policy_attachment {
	name = "replication"
	roles = [
		aws_iam_role.replication.name
	]
	policy_arn = aws_iam_policy.replication.arn
}
