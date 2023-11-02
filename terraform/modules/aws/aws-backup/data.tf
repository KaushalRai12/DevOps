data aws_iam_policy_document default {
	statement {
		sid = "AllowBackupService"

		actions = [
			"sts:AssumeRole",
		]

		effect = "Allow"

		principals {
			type = "Service"
			identifiers = [
				"backup.amazonaws.com"
			]
		}
	}
}

data aws_iam_policy_document sns_policy {

	statement {
		sid = "AllowSNSPublish"

		actions = [
			"SNS:Publish",
		]

		effect = "Allow"

		principals {
			type = "Service"
			identifiers = [
				"backup.amazonaws.com"
			]
		}

		resources = [aws_sns_topic.default.arn]
	}
}

data aws_iam_policy_document tagging {
	statement {
		sid = "AllowTaggingResources"

		actions = [
			"backup:TagResource",
			"backup:ListTags",
			"backup:UntagResource",
			"tag:GetResources"
		]

		resources = ["*"]
	}
}

data aws_kms_key backup {
	key_id = "alias/aws/backup"
}

data aws_kms_key sns_backup {
	key_id = "alias/aws/sns"
}

data aws_partition current {}
