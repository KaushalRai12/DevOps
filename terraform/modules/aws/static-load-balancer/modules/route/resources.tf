resource aws_lb_listener_rule rule {
	listener_arn = var.listener_arn

	action {
		type = "forward"
		target_group_arn = var.target_group_arn != null ? var.target_group_arn : one(aws_lb_target_group.target).arn
	}

	condition {
		host_header {
			values = setunion([local.domain], var.extra_domains)
		}
	}
}

resource aws_lb_target_group target {
	count = var.create_target_group ? 1 : 0
	name = var.target_group_name
	port = var.target_port
	protocol = var.target_protocol
	vpc_id = var.vpc_id
	target_type = var.target_type

	health_check {
		protocol = var.health_check_protocol
		matcher = "200-499"
	}
}

resource aws_lb_target_group_attachment target {
	for_each = var.create_target_group ? var.targets : []
	target_group_arn = one(aws_lb_target_group.target).arn
	target_id = each.value
	port = var.target_port
}

module certificate {
	count = var.encrypted && var.is_internal == false && var.certificate_arn == null ? 1 : 0
	source = "../../../certificate/modules/unwrapped"
	domain_name = local.domain
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
	is_internal = var.is_internal
}

resource aws_lb_listener_certificate certificate {
	count = var.encrypted && var.is_internal == false ? 1 : 0
	listener_arn = var.listener_arn
	certificate_arn = var.certificate_arn == null ? one(module.certificate).certificate_arn : var.certificate_arn
}

resource aws_route53_record dns {
	count = var.can_add_dns && local.we_control_domain ? 1 : 0
	zone_id = data.aws_route53_zone.root[0].id
	provider = aws.dns
	name = local.domain
	type = "CNAME"
	ttl = "300"
	records = [var.lb_dns]
}

module healthy_hosts_alarm {
	count = var.create_target_group ? 1 : 0
	source = "../../../cloudwatch-alarms/modules/alarm"
	alarm_name = "ec2-target-group-${var.target_group_name}-healthy-hosts"
	comparison_operator = "LessThanThreshold"
	threshold = 1
	period = "300"
	evaluation_periods = 3
	datapoints_to_alarm = 3
	namespace = "AWS/ApplicationELB"
	metric_name = "HealthyHostCount"
	dimensions = {
		TargetGroup = one(aws_lb_target_group.target).arn_suffix,
		LoadBalancer = var.lb_arn_suffix
	}
	statistic = "Minimum"
	alarm_actions = var.error_actions
	ok_actions = var.error_actions
	treat_missing_data = "breaching"
	tags = {
		category = "infrastucture"
		severity = "error"
	}
}

module response_time_alarm {
	count = var.create_target_group ? 1 : 0
	source = "../../../cloudwatch-alarms/modules/alarm"
	alarm_name = "ec2-target-group-${var.target_group_name}-response-time"
	comparison_operator = "GreaterThanThreshold"
	threshold = var.response_time_threshold
	period = "300"
	evaluation_periods = 6
	datapoints_to_alarm = 5
	namespace = "AWS/ApplicationELB"
	metric_name = "TargetResponseTime"
	dimensions = {
		TargetGroup = one(aws_lb_target_group.target).arn_suffix,
		LoadBalancer = var.lb_arn_suffix
	}
	statistic = "Average"
	alarm_actions = var.warning_actions
	ok_actions = var.warning_actions
	treat_missing_data = "notBreaching"
	tags = {
		category = "performance"
		severity = "warning"
	}
}
