# constants_env (prod)
locals {
	cluster_env = "prod"
	cluster_fqn = "${module.constants_cluster.cluster_name}-${local.cluster_env}"
	# TODO Change this to `vumatel-${module.constants_cluster.cluster_name}-${local.cluster_env}` at some point
	# k8s_context = "aex-${module.constants_cluster.cluster_name}-${local.cluster_env}"
	# k8s_context = "aex-vumatel-${local.cluster_env}"
	k8s_context = "vumatel-${local.cluster_env}"
	logs_bucket = "aex-vumatel-prod-logs"
	sns_notification_arn = "arn:aws:sns:af-south-1:774405590946:cloudwatch-alarms"
	sns_warning_arn = "arn:aws:sns:af-south-1:774405590946:cloudwatch-alarms"
	sns_error_arn = "arn:aws:sns:af-south-1:774405590946:cloudwatch-alarms"
}

data aws_vpc vpc {
	tags = {
		Name : "${replace(local.cluster_fqn, "-", "_")}_vpc"
	}
}

module constants_cluster {
	source = "../../../../modules/constants"
}

output vpc_id {
	value = data.aws_vpc.vpc.id
}

output vpc_cidr {
	value = data.aws_vpc.vpc.cidr_block
}

output cluster_fqn {
	value = local.cluster_fqn
}

output cluster_env {
	value = local.cluster_env
}

output k8s_context {
	value = local.k8s_context
}

output logs_bucket {
	value = local.logs_bucket
}

output sns_notification_arn {
	description = "SNS Topic to use for notifications"
	value = local.sns_notification_arn
}

output sns_warning_arn {
	description = "SNS Topic to use for warnings"
	value = local.sns_warning_arn
}

output sns_error_arn {
	description = "SNS Topic to use for errors"
	value = local.sns_error_arn
}
