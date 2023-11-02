resource aws_lb_target_group freeradius_authentication {
	name = "freerad-auth-${var.domain_environment}"
	port = local.authentication_port
	protocol = "UDP"
	vpc_id = var.vpc_id
	target_type = "instance"

	health_check {
		protocol = "HTTP"
		path = "/authenticate"
		port = 80
		matcher = "200-399"
	}

	lifecycle {
		create_before_destroy = true
	}
}

resource aws_lb_target_group freeradius_accounting {
	name = "freerad-acct-${var.domain_environment}"
	port = local.accounting_port
	protocol = "UDP"
	vpc_id = var.vpc_id
	target_type = "instance"

	health_check {
		protocol = "HTTP"
		path = "/accounting"
		port = 80
		matcher = "200-399"
	}

	lifecycle {
		create_before_destroy = true
	}
}

resource aws_lb_listener port_auth {
	load_balancer_arn = var.load_balancer_arn
	port = local.authentication_port
	protocol = "UDP"

	default_action {
		type = "forward"
		target_group_arn = aws_lb_target_group.freeradius_authentication.arn
	}
}

resource aws_lb_listener port_acct {
	load_balancer_arn = var.load_balancer_arn
	port = local.accounting_port
	protocol = "UDP"

	default_action {
		type = "forward"
		target_group_arn = aws_lb_target_group.freeradius_accounting.arn
	}
}

module authentication {
	source = "../../aws/static-servers/modules/static-server"

	subnet_ids = var.subnets

	servers_per_function = length(var.subnets)

	server_name = "freerad-auth"
	ami = var.ami_id
	patch_group = "ubuntu"
	cluster_env = var.cluster_env
	cluster_name = var.cluster_name
	key_name = "${var.key_prefix}nms-services"
	instance_type = var.instance_type
	security_group_ids = [resource.aws_security_group.auth_sg.id]
	extra_tags = {
		"aex/purpose" = "freeradius-authentication"
	}

	providers = {
		aws.dns = aws.dns
	}
}

module accounting {
	source = "../../aws/static-servers/modules/static-server"

	subnet_ids = var.subnets

	servers_per_function = length(var.subnets)

	server_name = "freerad-acct-1"
	ami = var.ami_id
	patch_group = "ubuntu"
	cluster_env = var.cluster_env
	cluster_name = var.cluster_name
	key_name = "${var.key_prefix}nms-services"
	instance_type = var.instance_type
	security_group_ids = [resource.aws_security_group.acct_sg.id]
	extra_tags = {
		"aex/purpose" = "freeradius-accounting"
	}

	providers = {
		aws.dns = aws.dns
	}
}

resource aws_lb_target_group_attachment authentication_targets {
	for_each = toset(data.aws_instances.authentication.ids)
	target_group_arn = aws_lb_target_group.freeradius_authentication.arn
	target_id = each.value
	port = local.authentication_port
}

resource aws_lb_target_group_attachment accounting_targets {
	for_each = toset(data.aws_instances.accounting.ids)
	target_group_arn = aws_lb_target_group.freeradius_accounting.arn
	target_id = each.value
	port = local.accounting_port
}

resource aws_security_group auth_sg {
	vpc_id = var.vpc_id

	name = "${var.cluster_fqn}_freeradius_auth_sg"
	description = "${var.cluster_fqn}_freeradius_auth_sg"

	tags = {
		Name = "${var.cluster_fqn}_freeradius_auth_sg"
	}
}

resource aws_security_group acct_sg {
	vpc_id = var.vpc_id

	name = "${var.cluster_fqn}_freeradius_acct_sg"
	description = "${var.cluster_fqn}_freeradius_acct_sg"

	tags = {
		Name = "${var.cluster_fqn}_freeradius_acct_sg"
	}
}

resource aws_security_group_rule auth_health_check {
	type = "ingress"
	from_port = 80
	to_port = 80
	protocol = "tcp"
	description = "FreeRADIUS Health Check"
	cidr_blocks = local.access_cidr_blocks
	security_group_id = resource.aws_security_group.auth_sg.id
}

resource aws_security_group_rule acct_health_check {
	type = "ingress"
	from_port = 80
	to_port = 80
	protocol = "tcp"
	description = "FreeRADIUS Health Check"
	cidr_blocks = local.access_cidr_blocks
	security_group_id = resource.aws_security_group.acct_sg.id
}

resource aws_security_group_rule radius_auth_ping {
	security_group_id = resource.aws_security_group.auth_sg.id
	type = "ingress"
	description = "Ping"
	from_port = 8
	to_port = 0
	protocol = "icmp"
	cidr_blocks = local.access_cidr_blocks
}

resource aws_security_group_rule radius_acct_ping {
	security_group_id = resource.aws_security_group.acct_sg.id
	type = "ingress"
	description = "Ping"
	from_port = 8
	to_port = 0
	protocol = "icmp"
	cidr_blocks = local.access_cidr_blocks
}

resource aws_security_group_rule radius_auth {
	type = "ingress"
	from_port = local.authentication_port
	to_port = local.authentication_port
	protocol = "udp"
	description = "FreeRADIUS Authentication"
	cidr_blocks = local.access_cidr_blocks
	security_group_id = resource.aws_security_group.auth_sg.id
}

resource aws_security_group_rule radius_acct {
	type = "ingress"
	from_port = local.accounting_port
	to_port = local.accounting_port
	protocol = "udp"
	description = "FreeRADIUS Accounting"
	cidr_blocks = local.access_cidr_blocks
	security_group_id = resource.aws_security_group.acct_sg.id
}

resource aws_security_group_rule auth_ssh {
	security_group_id = resource.aws_security_group.auth_sg.id
	type = "ingress"
	description = "VPN SSH"
	from_port = 22
	to_port = 22
	protocol = "tcp"
	cidr_blocks = setunion(module.constants.vumatel_access_cidrs)
}

resource aws_security_group_rule acct_ssh {
	security_group_id = resource.aws_security_group.acct_sg.id
	type = "ingress"
	description = "VPN SSH"
	from_port = 22
	to_port = 22
	protocol = "tcp"
	cidr_blocks = setunion(module.constants.vumatel_access_cidrs)
}

module auth_egress_all {
	source = "../../aws/networking/modules/egress-all"
	security_group_id = resource.aws_security_group.auth_sg.id
}

module acct_egress_all {
	source = "../../aws/networking/modules/egress-all"
	security_group_id = resource.aws_security_group.acct_sg.id
}

# resource aws_security_group_rule radius_auth {
# 	type = "ingress"
# 	from_port = 22
# 	to_port = 22
# 	protocol = "tcp"
# 	description = "SSH Access"
# 	cidr_blocks = local.access_cidr_blocks
# 	security_group_id = resource.aws_security_group.acct_sg.id
# }

# resource aws_security_group_rule radius_acct {
# 	type = "ingress"
# 	from_port = 22
# 	to_port = 22
# 	protocol = "tcp"
# 	description = "SSH Access"
# 	cidr_blocks = local.access_cidr_blocks
# 	security_group_id = resource.aws_security_group.auth_sg.id
# }


# module healthy_hosts_alarm {
#   count = var.create_target_group ? 1 : 0
#   source = "../../../cloudwatch-alarms/modules/alarm"
#   alarm_name = "ec2-target-group-${var.target_group_name}-healthy-hosts"
#   comparison_operator = "LessThanThreshold"
#   threshold = 1
#   period = "300"
#   evaluation_periods = 3
#   datapoints_to_alarm = 3
#   namespace = "AWS/ApplicationELB"
#   metric_name = "HealthyHostCount"
#   dimensions = {
#     TargetGroup = one(aws_lb_target_group.target).arn_suffix,
#     LoadBalancer = var.lb_arn_suffix
#   }
#   statistic = "Minimum"
#   alarm_actions = var.error_actions
#   ok_actions = var.error_actions
#   treat_missing_data = "breaching"
#   tags = {
#     category = "infrastucture"
#     severity = "error"
#   }
# }

# module response_time_alarm {
#   count = var.create_target_group ? 1 : 0
#   source = "../../../cloudwatch-alarms/modules/alarm"
#   alarm_name = "ec2-target-group-${var.target_group_name}-response-time"
#   comparison_operator = "GreaterThanThreshold"
#   threshold = var.response_time_threshold
#   period = "300"
#   evaluation_periods = 3
#   datapoints_to_alarm = 3
#   namespace = "AWS/ApplicationELB"
#   metric_name = "TargetResponseTime"
#   dimensions = {
#     TargetGroup = one(aws_lb_target_group.target).arn_suffix,
#     LoadBalancer = var.lb_arn_suffix
#   }
#   statistic = "Average"
#   alarm_actions = var.warning_actions
#   ok_actions = var.warning_actions
#   treat_missing_data = "notBreaching"
#   tags = {
#     category = "performance"
#     severity = "warning"
#   }
# }
