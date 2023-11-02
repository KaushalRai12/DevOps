module certificate {
	source = "../certificate/modules/unwrapped"
	for_each = { for service in local.external_service_map : service.name => service}
	domain_name = each.value.domain
	root_domain = each.value.root_domain
	providers = {
		aws.dns = aws.dns
	}
}

module internal_certificate {
	source = "../certificate/modules/unwrapped"
	for_each = local.has_any_secure_internal_route ? { for service in local.internal_service_map : service.name => service} : {}
	domain_name = each.value.domain
	root_domain = each.value.root_domain
	providers = {
		aws.dns = aws.dns
	}
	is_internal = true
}

module external_ingress {
	count = length(local.external_routes_chunked)
	source = "./modules/ingress"
	is_external = true
	routes = local.external_routes_chunked[count.index]
	index = count.index + 1
	k8s_namespace = var.k8s_namespace
	purpose = var.purpose
	logs_bucket = var.logs_bucket
	ssl_policy = var.ssl_policy
	has_auth = var.has_auth
	aws_profile = var.aws_profile
	connection_timeout = var.external_connection_timeout
	vpc_id = var.vpc_id
	is_dual_stack = var.is_dual_stack
	root_domain = var.external_root_domain
	internal_root_domain = var.internal_root_domain
	providers = {
		aws.dns: aws.dns
		aws.cognito: aws.cognito
	}
}

module internal_ingress {
	count = length(local.internal_routes) == 0 ? 0 : 1
	source = "./modules/ingress"
	is_external = false
	routes = local.internal_routes
	k8s_namespace = var.k8s_namespace
	purpose = var.purpose
	logs_bucket = var.logs_bucket
	ssl_policy = var.ssl_policy
	has_auth = var.has_auth
	aws_profile = var.aws_profile
	connection_timeout = var.internal_connection_timeout
	vpc_id = var.vpc_id
	is_dual_stack = var.is_dual_stack
	extra_ports = var.extra_internal_ports
	root_domain = var.internal_root_domain
	internal_root_domain = var.internal_root_domain
	providers = {
		aws.dns: aws.dns
		aws.cognito: aws.cognito
	}
}


