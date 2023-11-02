data template_file pub_subber_policy {
	template = file("${path.module}/templates/pub-subber-iam-policy.json.tpl")

	vars = {
		account_id = data.aws_caller_identity.current.account_id
		region = data.aws_region.current.name
	}
}

resource aws_iam_policy pub_subber {
	name = "aex-pub-subber"
	description = "Allows all actions necessary for an app to operate SNS-SQS pub/sub."

	policy = data.template_file.pub_subber_policy.rendered
}

resource aws_iam_group pub_subbers {
	name = "pub-subbers"
}

resource aws_iam_group_policy_attachment pub_subbers {
	group = aws_iam_group.pub_subbers.name
	policy_arn = aws_iam_policy.pub_subber.arn
}

resource aws_iam_user pub_sub_service {
	name = "pub-sub-service"
}

resource aws_iam_user_group_membership pub_subber {
	user = aws_iam_user.pub_sub_service.name
	groups = [aws_iam_group.pub_subbers.name]
}

data aws_iam_policy_document external_subber {
	statement {
		effect = "Allow"
		actions = [
			"sns:ConfirmSubscription",
			"sns:GetTopicAttributes",
			"sns:ListSubscriptionsByTopic",
			"sns:ListTagsForResource",
			"sns:Subscribe",
			"sqs:ChangeMessageVisibility",
			"sqs:ChangeMessageVisibilityBatch",
			"sqs:CreateQueue",
			"sqs:DeleteMessage",
			"sqs:DeleteMessageBatch",
			"sqs:GetQueueAttributes",
			"sqs:GetQueueUrl",
			"sqs:ListDeadLetterSourceQueues",
			"sqs:ListQueueTags",
			"sqs:PurgeQueue",
			"sqs:ReceiveMessage",
			"sqs:SendMessage",
			"sqs:SendMessageBatch",
			"sqs:SetQueueAttributes",
			"sqs:TagQueue",
			"sqs:UntagQueue"
		]
		resources = [
			"arn:aws:sns:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
			"arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
		]
	}

	statement {
		effect = "Allow"
		actions = [
			"sns:CheckIfPhoneNumberIsOptedOut",
			"sns:CreatePlatformApplication",
			"sns:CreatePlatformEndpoint",
			"sns:CreateSMSSandboxPhoneNumber",
			"sns:GetEndpointAttributes",
			"sns:GetPlatformApplicationAttributes",
			"sns:GetSMSAttributes",
			"sns:GetSMSSandboxAccountStatus",
			"sns:GetSubscriptionAttributes",
			"sns:ListEndpointsByPlatformApplication",
			"sns:ListOriginationNumbers",
			"sns:ListPhoneNumbersOptedOut",
			"sns:ListPlatformApplications",
			"sns:ListSMSSandboxPhoneNumbers",
			"sns:ListSubscriptions",
			"sns:ListTopics",
			"sns:OptInPhoneNumber",
			"sns:SetEndpointAttributes",
			"sns:SetPlatformApplicationAttributes",
			"sns:SetSMSAttributes",
			"sns:SetSubscriptionAttributes",
			"sns:Unsubscribe",
			"sns:VerifySMSSandboxPhoneNumber",
			"sqs:ListQueues"
		]
		resources = ["*"]
	}
}

resource aws_iam_policy external_subber {
	name = "aex-external-subber"
	description = "Allows all actions necessary for an external app to subscribe to topics."

	policy = data.aws_iam_policy_document.external_subber.json
}

resource aws_iam_group external_subbers {
	name = "external-subbers"
}

resource aws_iam_group_policy_attachment external_subbers {
	group = aws_iam_group.external_subbers.name
	policy_arn = aws_iam_policy.external_subber.arn
}

resource aws_iam_user external_subber {
	name = "external-subber"
}

resource aws_iam_user_group_membership external_subber {
	user = aws_iam_user.external_subber.name
	groups = [aws_iam_group.external_subbers.name]
}

module terraformers {
	source = "../terraformers"
}

module k8s {
	source = "../k8s"
}

resource aws_iam_role rds_enhanced_monitoring {
	name = "aex-rds-enhanced-monitoring"
	assume_role_policy = data.aws_iam_policy_document.rds_enhanced_monitoring.json
}

resource aws_iam_role_policy_attachment rds_enhanced_monitoring {
	role = aws_iam_role.rds_enhanced_monitoring.name
	policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data aws_iam_policy_document rds_enhanced_monitoring {
	statement {
		actions = [
			"sts:AssumeRole",
		]

		effect = "Allow"

		principals {
			type = "Service"
			identifiers = ["monitoring.rds.amazonaws.com"]
		}
	}
}

resource aws_iam_group db_administrators {
	name = "db-administrators"
}

resource aws_iam_group_policy_attachment db_administrators {
	group = aws_iam_group.db_administrators.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

data aws_iam_policy_document ec2_role {
	statement {
		effect = "Allow"
		actions = [
			"sts:AssumeRole",
		]
		principals {
			type = "Service"
			identifiers = ["ec2.amazonaws.com"]
		}
	}
}

resource aws_iam_role ec2_role {
	name = "aex-ec2-instance-role"
	path = "/service-role/"
	assume_role_policy = data.aws_iam_policy_document.ec2_role.json

	force_detach_policies = false
	managed_policy_arns = [
		"arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
		"arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole",
		"arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
	]

	max_session_duration = 3600
}

resource aws_iam_instance_profile ec2_profile {
	name = module.constants.ec2_instance_profile
	role = aws_iam_role.ec2_role.name
}

data aws_iam_policy_document dms_starter {
	statement {
		effect = "Allow"
		actions = [
			"dms:StartReplicationTask"
		]
		resources = [
			"arn:aws:dms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:task:*",
		]
	}
}

resource aws_iam_policy dms_starter {
	name = "aex-dms-starter"
	policy = data.aws_iam_policy_document.dms_starter.json
}

resource aws_iam_role_policy_attachment dms_starter {
  role = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.dms_starter.arn
}

data aws_iam_policy_document allow_own_password_change {

	statement {
		actions = ["iam:GetAccountPasswordPolicy"]
		effect = "Allow"
		resources = ["*"]
	}

	statement {
		actions = ["iam:ChangePassword"]
		effect = "Allow"
		resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/$${aws:username}"]
	}
}

resource aws_iam_policy change_password {
	name = "aex-change-own-password"
	description = "Attach to users so they can change their own passwords"
	policy = data.aws_iam_policy_document.allow_own_password_change.json
}

// Temporary, until role access is sorted
resource aws_iam_user prometheus {
	name = "prometheus"
}

resource aws_iam_user_policy_attachment prometheus {
	user = aws_iam_user.prometheus.name
	policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

data aws_iam_policy_document prometheus_trust {
	statement {
		actions = ["sts:AssumeRole"]

		effect = "Allow"

		principals {
			type = "Service"
			identifiers = ["ec2.amazonaws.com"]
		}
	}
}

data aws_iam_policy_document prometheus {
	statement {
		effect = "Allow"
		actions = ["ec2:Describe*"]
		resources = ["*"]
	}

	statement {
		effect = "Allow"
		actions = ["elasticloadbalancing:Describe*"]
		resources = ["*"]
	}

	statement {
		effect = "Allow"
		actions = ["autoscaling:Describe*"]
		resources = ["*"]
	}

	statement {
		effect = "Allow"
		actions = [
			"cloudwatch:ListMetrics",
			"cloudwatch:GetMetricStatistics",
			"cloudwatch:Describe*",
		]
		resources = ["*"]
	}
}

resource aws_iam_role prometheus {
	name = "aex-prometheus"
	assume_role_policy = data.aws_iam_policy_document.prometheus_trust.json
}

resource aws_iam_policy prometheus {
	name = "aex-prometheus"
	policy = data.aws_iam_policy_document.prometheus.json
}

resource aws_iam_role_policy_attachment prometheus {
	role = aws_iam_role.prometheus.name
	policy_arn = aws_iam_policy.prometheus.arn
}

resource aws_iam_instance_profile prometheus {
	name = "aex-prometheus"

	role = aws_iam_role.prometheus.name
}

data aws_iam_policy_document eks_node_instance {
	statement {
		effect = "Allow"
		actions = ["sts:AssumeRole"]
		resources = ["*"]
	}
}

resource aws_iam_policy eks_node_instance {
	name = module.constants.eks_node_instance_policy
	policy = data.aws_iam_policy_document.eks_node_instance.json
}

