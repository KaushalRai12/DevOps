module route {
	source = "../../../static-load-balancer/modules/route"
	listener_arn = var.listener_arn
	domain = local.portal_domain
	lb_dns = var.lb_dns
	lb_arn_suffix = var.lb_arn_suffix
	root_domain = var.external_root_domain
	extra_domains = var.extra_domains
	target_port = var.target_port
	targets = var.portal_server_ids
	vpc_id = var.vpc_id
	target_protocol = "HTTPS"
	health_check_protocol = var.health_check_protocol
	can_add_dns = var.can_add_dns
	certificate_arn = var.certificate_arn
	target_group_name = coalesce(var.target_group_name, local.target_group_name)
	error_actions = var.error_actions
	warning_actions = var.warning_actions
	providers = {
		aws.dns = aws.dns
	}
}

module internal_route {
	count = var.internal_listener_arn == null ? 0 : 1
	source = "../../../static-load-balancer/modules/route"
	listener_arn = var.internal_listener_arn
	domain = local.internal_portal_domain
	lb_dns = var.internal_lb_dns
	lb_arn_suffix = var.lb_arn_suffix
	root_domain = var.internal_root_domain
	target_port = var.target_port
	targets = var.portal_server_ids
	vpc_id = var.vpc_id
	target_protocol = "HTTPS"
	health_check_protocol = var.health_check_protocol
	target_group_name = local.internal_target_group_name
	error_actions = var.error_actions
	warning_actions = var.warning_actions
	is_internal = true
	providers = {
		aws.dns = aws.dns
	}
}
