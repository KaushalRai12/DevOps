resource aws_s3_bucket lb_logs {
	bucket = var.log_bucket_name
}

resource aws_s3_bucket_acl lb_logs {
	bucket = aws_s3_bucket.lb_logs.id
	acl = "private"
}

resource aws_s3_bucket_public_access_block bucket_access_block {
	bucket = aws_s3_bucket.lb_logs.id

	block_public_acls = true
	block_public_policy = true
	ignore_public_acls = true
	restrict_public_buckets = true
}

resource aws_s3_bucket_lifecycle_configuration remove_old_logs {
	bucket = aws_s3_bucket.lb_logs.bucket

	rule {
		id = "remove-old-logs"
		status = "Enabled"
		expiration {
			days = var.expiry_days
		}
	}
}

resource aws_s3_bucket_server_side_encryption_configuration lb_logs {
	bucket = aws_s3_bucket.lb_logs.bucket
	rule {
		apply_server_side_encryption_by_default {
			sse_algorithm = "aws:kms"
		}
	}
}

resource aws_s3_bucket_versioning lb_logs {
	bucket = aws_s3_bucket.lb_logs.id
	versioning_configuration {
		status = "Enabled"
	}
}

resource aws_s3_bucket_policy s3_bucket_policy {
	bucket = aws_s3_bucket.lb_logs.id

	policy = data.aws_iam_policy_document.s3_bucket_policy.json
}

data aws_iam_policy_document s3_bucket_policy {
	statement {
		sid = "AExlogsAcl1"
		effect = "Allow"
		principals {
			type = "AWS"
			identifiers = [
				data.aws_caller_identity.current.account_id,
				data.aws_elb_service_account.main.arn,
			]
		}
		actions = ["s3:*"]
		resources = ["arn:aws:s3:::${aws_s3_bucket.lb_logs.bucket}"]
	}

	statement {
		sid = "AExlogsAcl2"
		effect = "Allow"
		principals {
			type = "AWS"
			identifiers = [
				data.aws_caller_identity.current.account_id,
				data.aws_elb_service_account.main.arn,
			]
		}
		actions = ["s3:*"]
		resources = ["arn:aws:s3:::${aws_s3_bucket.lb_logs.bucket}/*"]
	}


  statement {
    sid = "AWSLogDeliveryWrite"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
		resources = ["arn:aws:s3:::${aws_s3_bucket.lb_logs.bucket}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control"
      ]
    }
  }

  statement {
    sid = "AWSLogDeliveryAclCheck"
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }
    actions = [
      "s3:GetBucketAcl"
    ]
		resources = ["arn:aws:s3:::${aws_s3_bucket.lb_logs.bucket}"]
  }
}
