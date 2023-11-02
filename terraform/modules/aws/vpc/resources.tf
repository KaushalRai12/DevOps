resource aws_vpc vpc {
	cidr_block = var.vpc_cidr
	enable_dns_support = true
	enable_dns_hostnames = true
	instance_tenancy = "default"
	tags = {
		Name : "${var.cluster_fqn}_vpc"
		"aex/vpc/cidr" : local.actual_vpc_cidr
	}
}

resource aws_flow_log flowlog_cloudwatch {
	iam_role_arn = aws_iam_role.flowlog_role_cloudwatch.arn
	log_destination = aws_cloudwatch_log_group.flowlog_log_group.arn
	traffic_type = "ALL"
	vpc_id = aws_vpc.vpc.id
	tags = {
		Name = "${var.cluster_fqn}_cloudwatch_flowlog"
	}
}

resource aws_cloudwatch_log_group flowlog_log_group {
	name = "${var.cluster_fqn}_flowlog"
	retention_in_days = 30

	lifecycle {
		create_before_destroy = true
		prevent_destroy       = false
	}
}

resource aws_iam_role flowlog_role_cloudwatch {
	name = "${var.cluster_fqn}_flowlog_role_cloudwatch"
	assume_role_policy = file("${path.module}/templates/flow-log-cloudwatch-role.json")
}

resource aws_iam_role_policy flowlog_policy_cloudwatch {
	name = "${var.cluster_fqn}_flowlog_policy_cloudwatch"
	role = aws_iam_role.flowlog_role_cloudwatch.id

	policy = file("${path.module}/templates/flow-log-policy.json")
}

resource aws_flow_log flowlog_s3 {
	log_destination = var.logs_bucket_arn
	log_destination_type = "s3"
	traffic_type = "ALL"
	vpc_id = aws_vpc.vpc.id
	tags = {
		Name = "${var.cluster_fqn}_s3_flowlog"
	}
}

resource aws_vpn_gateway vpc_gateway {
	vpc_id = aws_vpc.vpc.id
	tags = {
		Name = replace(var.cluster_fqn, "_", "-")
	}
}
