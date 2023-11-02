module route {
	for_each = local.routes
	source = "../unwrapped"
	vpc_id = var.vpc_id
	portal_server_ids = var.portal_server_ids
	target_port = 443
	domain_environment = var.domain_environment
	cluster_name = var.cluster_name
	portal_name = each.value.name
	target_group_name = local.target_group_name
	external_root_domain = each.value.root_domain
	listener_arn = var.listener_arn
	lb_dns = var.lb_dns
	lb_arn_suffix = var.lb_arn_suffix
	providers = {
		aws.dns = aws.dns
	}
}
