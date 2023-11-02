resource aws_kms_key cloud_trail {
	description = "Cloud Trail key"
	customer_master_key_spec = "SYMMETRIC_DEFAULT"
	multi_region = true
	policy = data.aws_iam_policy_document.key.json
}

resource aws_cloudwatch_log_group this {
	name = "aex-cloudtrail-logs"
	retention_in_days = 30
}

resource aws_iam_role cloud_trail {
	name = "aex-cloudtrail-cloudwatch"
	assume_role_policy = data.aws_iam_policy_document.cloud_trail_role.json
}

resource aws_cloudtrail this {
	name = "${var.org_prefix}-${replace(var.cluster_name, "_", "-")}"
	s3_bucket_name = aws_s3_bucket.this.id
	enable_log_file_validation = true
	kms_key_id = aws_kms_key.cloud_trail.arn
	is_multi_region_trail = true
	include_global_service_events = true
	is_organization_trail = var.is_organization_trail
	cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.this.arn}:*"
	cloud_watch_logs_role_arn = aws_iam_role.cloud_trail.arn
	insight_selector {
		insight_type = "ApiCallRateInsight"
	}
	insight_selector {
		insight_type = "ApiErrorRateInsight"
	}
	tags = {
		Name: "${var.org_prefix}-${replace(var.cluster_name, "_", "-")}"
	}
}

resource aws_s3_bucket this {
	bucket = "${var.org_prefix}-cloudtrail-${replace(var.cluster_name, "_", "-")}"
}

resource aws_s3_bucket_public_access_block this {
	bucket = aws_s3_bucket.this.id
	block_public_acls = true
	block_public_policy = true
	ignore_public_acls = true
	restrict_public_buckets = true
}

data aws_iam_policy_document bucket {
	statement {
		effect = "Allow"
		principals {
			type = "Service"
			identifiers = ["cloudtrail.amazonaws.com"]
		}
		actions = ["s3:*"]
		resources = [aws_s3_bucket.this.arn]
	}

	statement {
		effect = "Allow"
		principals {
			type = "Service"
			identifiers = ["cloudtrail.amazonaws.com"]
		}
		actions = ["s3:*"]
		resources = ["${aws_s3_bucket.this.arn}/*"]
	}
}

resource aws_s3_bucket_policy this {
	bucket = aws_s3_bucket.this.id
	policy = data.aws_iam_policy_document.bucket.json
}

data aws_iam_policy_document key {
	statement {
		sid = "Enable IAM User Permissions"
		effect = "Allow"
		principals {
			type = "AWS"
			identifiers = [
				"arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraformer",
				"arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
				"arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-reserved/sso.amazonaws.com/eu-west-1/AWSReservedSSO_VumAEX-devops_4b61fcacf112ab24",
			]
		}
		actions = ["kms:*"]
		resources = ["*"]
	}

	statement {
		sid = "Allow CloudTrail to encrypt logs"
		effect = "Allow"
		principals {
			type = "Service"
			identifiers = ["cloudtrail.amazonaws.com"]
		}
		actions = ["kms:GenerateDataKey*"]
		resources = ["*"]
		condition {
			test = "StringLike"
			variable = "kms:EncryptionContext:aws:cloudtrail:arn"
			values = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
		}
	}

	statement {
		sid = "Allow CloudTrail to describe key"
		effect = "Allow"
		principals {
			type = "Service"
			identifiers = ["cloudtrail.amazonaws.com"]
		}
		actions = ["kms:DescribeKey"]
		resources = ["*"]
	}

	statement {
		sid = "Allow alias creation during setup"
		effect = "Allow"
		principals {
			type = "AWS"
			identifiers = ["*"]
		}
		actions = ["kms:CreateAlias"]
		resources = ["*"]
		condition {
			test = "StringEquals"
			variable = "kms:CallerAccount"
			values = [data.aws_caller_identity.current.account_id]
		}
	}

	statement {
		sid = "Allow principals in the account to decrypt log files"
		effect = "Allow"
		principals {
			type = "AWS"
			identifiers = ["*"]
		}
		actions = [
			"kms:Decrypt",
			"kms:ReEncryptFrom",
		]
		resources = ["*"]
		condition {
			test = "StringEquals"
			variable = "kms:CallerAccount"
			values = [data.aws_caller_identity.current.account_id]
		}
		condition {
			test = "StringLike"
			variable = "kms:EncryptionContext:aws:cloudtrail:arn"
			values = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
		}
	}
}

resource aws_kms_alias cloud_trail {
	target_key_id = aws_kms_key.cloud_trail.id
	name = "alias/${var.org_prefix}-${replace(var.cluster_name, "_", "-")}-cloudtrail"
}

data aws_iam_policy_document cloud_trail_role {
	statement {
		effect = "Allow"
		principals {
			type = "Service"
			identifiers = ["cloudtrail.amazonaws.com"]
		}
		actions = ["sts:AssumeRole"]
	}
}

data aws_iam_policy_document cloud_trail {
	statement {
		effect = "Allow"
		actions = [
			"logs:CreateLogStream",
			"logs:PutLogEvents",
		]
		resources = ["${aws_cloudwatch_log_group.this.arn}:*"]
	}
}

resource aws_iam_role_policy cloud_watch {
	name = "aex-cloudtrail-cloudwatch-policy"
	role = aws_iam_role.cloud_trail.id
	policy = data.aws_iam_policy_document.cloud_trail.json
}
