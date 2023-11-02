module route_external_443 {
	source = "../route"
	extra_domains = var.extra_external_domains
	listener_arn = var.port_443_arn
	domain = local.external_domain
	lb_dns = var.external_lb_dns
	lb_arn_suffix = var.external_lb_arn_suffix
	vpc_id = var.vpc_id
	target_port = var.target_port
	target_group_name = replace(local.target_group_name, "|", "")
	targets = var.targets
	root_domain = var.external_root_domain
	error_actions = var.error_actions
	warning_actions = var.warning_actions
	providers = {
		aws.dns = aws.dns
	}
}

module route_internal_443 {
	source = "../route"
	extra_domains = var.extra_internal_domains
	listener_arn = var.port_443_internal_arn
	domain = local.internal_domain
	target_group_name = replace(local.target_group_name, "|", "-itnl")
	target_port = var.target_port
	targets = var.targets
	lb_dns = var.internal_lb_dns
	lb_arn_suffix = var.internal_lb_arn_suffix
	vpc_id = var.vpc_id
	root_domain = var.internal_root_domain
	error_actions = var.error_actions
	warning_actions = var.warning_actions
	is_internal = true
	providers = {
		aws.dns = aws.dns
	}
}

module route_internal_80 {
	source = "../route"
	extra_domains = var.extra_internal_domains
	listener_arn = var.port_80_internal_arn
	domain = local.internal_domain
	target_group_arn = module.route_internal_443.target_group_arn
	create_target_group = false
	encrypted = false
	can_add_dns = false
	lb_dns = var.internal_lb_dns
	lb_arn_suffix = var.internal_lb_arn_suffix
	vpc_id = var.vpc_id
	root_domain = var.internal_root_domain
	error_actions = var.error_actions
	warning_actions = var.warning_actions
	is_internal = true
	providers = {
		aws.dns = aws.dns
	}
}
