module route {
	source = "./modules/unwrapped"
	external_root_domain = var.external_root_domain
	internal_root_domain = var.internal_root_domain
	extra_domains = var.extra_domains
	lb_dns = var.lb_dns
	lb_arn_suffix = var.lb_arn_suffix
	listener_arn = var.listener_arn
	internal_lb_dns = var.internal_lb_dns
	internal_listener_arn = var.internal_listener_arn
	portal_server_ids = var.portal_server_ids
	domain_environment = var.domain_environment
	portal_name = var.portal_name
	vpc_id = var.vpc_id
	can_add_dns = var.can_add_dns
	target_group_name = var.target_group_name
	cluster_name = var.cluster_name
	domain_name = var.domain_name
	certificate_arn = var.certificate_arn
	error_actions = var.error_actions
	warning_actions = var.warning_actions
	providers = {
		aws.dns = aws.dns
	}
}
