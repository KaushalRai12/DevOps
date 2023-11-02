module api_client_prepaid_vumatel_route {
	source = "../../../../../../modules/aws/static-load-balancer/modules/extra_route"
	load_balancer_dns_name = "${replace(module.constants_env.cluster_fqn, "_", "-")}-ip-external"
	domain = "api.client-prepaid.vumatel.${module.constants.aex_legacy_domain}"
	root_domain = module.constants.aex_legacy_domain
	cluster_fqn = local.cluster_fqn
	providers = {
		aws.dns = aws.dns
	}
}

module api_client_prepaid_route {
	source = "../../../../../../modules/aws/static-load-balancer/modules/route"
	listener_arn = data.aws_lb_listener.static_443.arn
	domain = "api.client-prepaid.${module.constants.aex_legacy_domain}"
	extra_domains = ["api.client-prepaid.vumatel.${module.constants.aex_legacy_domain}"]
	lb_dns = data.aws_lb.external_ip.dns_name
	lb_arn_suffix = data.aws_lb.static.arn_suffix
	root_domain = module.constants.aex_legacy_domain
	target_port = 443
	targets = data.aws_instances.portal.ids
	vpc_id = module.constants_env.vpc_id
	target_protocol = "HTTPS"
	health_check_protocol = "HTTPS"
	target_group_name = "api-client-prepaid"
	error_actions = local.error_actions
	warning_actions = local.warning_actions
	response_time_threshold = 1
	providers = {
		aws.dns = aws.dns
	}
}

module notification_route {
	source = "../../../../../../modules/aws/static-load-balancer/modules/route"
	listener_arn = data.aws_lb_listener.static_443.arn
	domain = "notification.vumatel.${module.constants.aex_legacy_domain}"
	lb_dns = data.aws_lb.static.dns_name
	lb_arn_suffix = data.aws_lb.static.arn_suffix
	root_domain = module.constants.aex_legacy_domain
	target_port = 443
	targets = data.aws_instances.portal.ids
	vpc_id = module.constants_env.vpc_id
	target_protocol = "HTTPS"
	health_check_protocol = "HTTPS"
	target_group_name = "notification-portal"
	error_actions = local.error_actions
	warning_actions = local.warning_actions
	response_time_threshold = 1
	providers = {
		aws.dns = aws.dns
	}
}

module status_route {
	source = "../../../../../../modules/aws/static-load-balancer/modules/route"
	listener_arn = data.aws_lb_listener.static_443.arn
	domain = "status.vumatel.${module.constants.aex_legacy_domain}"
	lb_dns = data.aws_lb.static.dns_name
	lb_arn_suffix = data.aws_lb.static.arn_suffix
	root_domain = module.constants.aex_legacy_domain
	target_port = 9111
	targets = data.aws_instances.api.ids
	vpc_id = module.constants_env.vpc_id
	target_group_name = "status"
	error_actions = local.error_actions
	warning_actions = local.warning_actions
	response_time_threshold = 1
	providers = {
		aws.dns = aws.dns
	}
}
