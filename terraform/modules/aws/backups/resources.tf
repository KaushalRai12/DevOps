resource aws_s3_bucket backups {
	bucket = "${var.org_prefix}-backups-${replace(var.cluster_name, "_", "-")}"
}

resource aws_s3_bucket_acl backups {
	bucket = aws_s3_bucket.backups.id
	acl = "private"
}

resource aws_s3_object ad_hoc_folder {
	bucket = aws_s3_bucket.backups.id
	key = "ad-hoc/"
	source = "/dev/null"
}

resource aws_s3_bucket_server_side_encryption_configuration backups {
	bucket = aws_s3_bucket.backups.bucket
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "aws:kms"
		}
	}
}

resource aws_s3_bucket_lifecycle_configuration backups {
	bucket = aws_s3_bucket.backups.bucket

	rule {
		id = "daily"
		status = "Enabled"

		filter {
			prefix = "daily/"
		}

		expiration {
			days = 60
		}
	}

	rule {
		id = "weekly"
		status = "Enabled"

		filter {
			prefix = "weekly/"
		}

		transition {
			days = 60
			storage_class = "DEEP_ARCHIVE"
		}

		expiration {
			days = 730
		}
	}

	rule {
		id = local.ad_hoc_folder
		status = "Enabled"

		filter {
			prefix = "${local.ad_hoc_folder}/"
		}

		transition {
			days = 60
			storage_class = "DEEP_ARCHIVE"
		}

		expiration {
			days = 365
		}
	}
}

resource aws_s3_bucket_versioning lb_logs {
	bucket = aws_s3_bucket.backups.id
	versioning_configuration {
		status = "Suspended"
	}
}

resource aws_s3_bucket_public_access_block bucket_access_block {
	bucket = aws_s3_bucket.backups.id

	block_public_acls = true
	block_public_policy = true
	ignore_public_acls = true
	restrict_public_buckets = true
}

resource aws_iam_policy backups {
	name = "${var.org_prefix}-backups"
	path = "/"
	policy = data.aws_iam_policy_document.backups.json
}

resource aws_iam_user backups {
	name = "backer-upper"
}

resource aws_iam_user_policy_attachment backups {
	user = aws_iam_user.backups.name
	policy_arn = aws_iam_policy.backups.arn
}

resource aws_iam_policy manual_backups {
	name = "${var.org_prefix}-manual-backups"
	path = "/"
	policy = data.aws_iam_policy_document.manual_backups.json
}

resource aws_iam_role manual_backups {
	name = module.constants.manual_backups_role
	assume_role_policy = data.aws_iam_policy_document.rds.json
}

resource aws_iam_role_policy_attachment manual_backups {
	policy_arn = aws_iam_policy.manual_backups.arn
	role = aws_iam_role.manual_backups.name
}
