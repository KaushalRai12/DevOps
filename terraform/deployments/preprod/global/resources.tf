module general {
	source = "../../../modules/aws/general"
	root_domain = module.constants.aex_i11l_systems_domain
	providers = {
		aws.dns = aws.operations
	}
}

# See https://bahr.dev/2022/02/07/org-formation/
module budgets {
	source = "../../../modules/aws/budgets"
	limit_amount = local.limit_amount
}

module ebs_encryption {
	source = "../../../modules/aws/ebs-encryption"
	enabled = false
}

resource aws_iam_service_linked_role es {
	aws_service_name = "es.amazonaws.com"
	description = "Allows Amazon ES to manage AWS resources for a domain on your behalf."
}

module global_logs {
	source = "../../../modules/aws/log-bucket"
	log_bucket_name = module.constants_cluster.logs_bucket
}

module patch_management {
  source = "../../../modules/aws/patch-management"
	logs_bucket = module.global_logs.bucket
}

module s3_backups {
	source = "../../../modules/aws/backups"
	cluster_name = module.constants_cluster.cluster_name
}

// todo: fix the slack webhook URL to point to vumatel slack
module slack_notifications {
	source = "../../../modules/apps/slack-notifications-lambda"
	providers = {
		aws.secrets = aws.operations
	}
}
