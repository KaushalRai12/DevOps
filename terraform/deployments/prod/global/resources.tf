module general {
  source = "../../../modules/aws/general"
  providers = {
    aws.dns = aws.dns
  }
}

module global_logs {
	source = "../../../modules/aws/log-bucket"
  log_bucket_name = module.constants_cluster.logs_bucket
}

module cognito_app {
  source = "../../../modules/aws/operations-user-pool"
  providers = {
    aws = aws.eu
  }
  domain_suffix = "vumatel"
  redirect_guid = "fc488917-6d09-4a8c-a741-1cca1bb2333d"
}

module patch_management {
	source = "../../../modules/aws/patch-management"
  logs_bucket = module.global_logs.bucket
}

module budgets {
	source = "../../../modules/aws/budgets"
  limit_amount = local.limit_amount
}

module ebs_encryption {
	source = "../../../modules/aws/ebs-encryption"
  enabled = true
}

resource aws_iam_service_linked_role es {
  aws_service_name = "es.amazonaws.com"
	description = "Allows Amazon ES to manage AWS resources for a domain on your behalf."
}

module s3_backups {
	source = "../../../modules/aws/backups"
  cluster_name = "prod"
}

resource aws_iam_user vumaex_tv {
  name = "vumaex-tv"
  force_destroy = true
}

resource aws_iam_user_policy vumaex_tv_policy {
  name = "vumaex-tv-policy"
  user = aws_iam_user.vumaex_tv.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
		"cloudwatch:GetDashboard",
      	"cloudwatch:ListDashboards",
		"cloudwatch:GetMetricData",
		"cloudwatch:DescribeAlarm*",
		"logs:FilterLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource aws_iam_user_login_profile vumaex_tv_profile {
  user    				  = aws_iam_user.vumaex_tv.name
  password_reset_required = false
}
