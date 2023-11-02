variable cluster_name {
	type = string
}

variable org_prefix {
	description = "Organisational prefix for your bucket"
	type = string
	default = "aex"
}

locals {
	ad_hoc_folder = "ad-hoc"
}

module constants {
	source = "../constants"
}

data aws_iam_policy_document backups {
	statement {
		sid = "1"

		actions = ["s3:PutObject"]

		resources = [
			"${aws_s3_bucket.backups.arn}/*",
		]
	}
}

data aws_iam_policy_document manual_backups {
	statement {
		sid = "1"
		effect = "Allow"

		actions = ["s3:ListBucket", "s3:GetBucketLocation"]

		resources = [
			aws_s3_bucket.backups.arn,
		]
	}

	statement {
		sid = "2"
		effect = "Allow"
		actions = [
			"s3:GetObjectMetaData",
			"s3:GetObject",
			"s3:PutObject",
			"s3:ListMultipartUploadParts",
			"s3:AbortMultipartUpload",
		]

		resources = [
			"${aws_s3_bucket.backups.arn}/ad-hoc/*",
		]
	}
}

data aws_iam_policy_document rds {
	statement {
		actions = ["sts:AssumeRole"]

		effect = "Allow"

		principals {
			type = "Service"
			identifiers = ["rds.amazonaws.com"]
		}
	}
}
