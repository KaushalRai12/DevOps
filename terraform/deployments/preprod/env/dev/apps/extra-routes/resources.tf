module fno_route_vumatel {
	source = "../../../../../../modules/aws/static-load-balancer/modules/route"
	listener_arn = data.aws_lb_listener.static_443.arn
	domain = "preprod-fno.vumatel.${module.constants.aex_za_client_facing_domain}"
	lb_dns = data.aws_lb.static.dns_name
	lb_arn_suffix = data.aws_lb.static.arn_suffix
	root_domain = module.constants.aex_za_client_facing_domain
	target_port = 9301
	targets = data.aws_instances.api.ids
	vpc_id = module.constants_env.vpc_id
	target_group_name = "preprod-fno"
	providers = {
		aws.dns = aws.operations
	}
}

module fno_route {
	source = "../../../../../../modules/aws/static-load-balancer/modules/route"
	listener_arn = data.aws_lb_listener.static_443.arn
	domain = "preprod.fno.${module.constants.aex_za_client_facing_domain}"
	lb_dns = data.aws_lb.static.dns_name
	lb_arn_suffix = data.aws_lb.static.arn_suffix
	root_domain = module.constants.aex_za_client_facing_domain
	target_port = 9301
	targets = data.aws_instances.api.ids
	vpc_id = module.constants_env.vpc_id
	target_group_name = "preprod-fno"
	providers = {
		aws.dns = aws.operations
	}
}

module stage_status_route {
	source = "../../../../../../modules/aws/static-load-balancer/modules/route"
	listener_arn = data.aws_lb_listener.static_443.arn
	domain = "stage.status.dev.${module.constants.aex_i11l_systems_domain}"
	lb_dns = data.aws_lb.static.dns_name
	lb_arn_suffix = data.aws_lb.static.arn_suffix
	target_port = 9112
	targets = data.aws_instances.api.ids
	vpc_id = module.constants_env.vpc_id
	target_group_name = "stage-status"
	providers = {
		aws.dns = aws.operations
	}
}

module preprod_status_route {
	source = "../../../../../../modules/aws/static-load-balancer/modules/route"
	listener_arn = data.aws_lb_listener.static_443.arn
	domain = "preprod.status.dev.${module.constants.aex_i11l_systems_domain}"
	lb_dns = data.aws_lb.static.dns_name
	lb_arn_suffix = data.aws_lb.static.arn_suffix
	target_port = 9111
	targets = data.aws_instances.api.ids
	vpc_id = module.constants_env.vpc_id
	target_group_name = "preprod-status"
	providers = {
		aws.dns = aws.operations
	}
}

module stage_api_client_prepaid_route {
	source = "../../../../../../modules/aws/static-load-balancer/modules/route"
	listener_arn = data.aws_lb_listener.static_443.arn
	domain = "stage.api.client-prepaid.${module.constants.aex_za_client_facing_domain}"
	lb_dns = data.aws_lb.static.dns_name
	lb_arn_suffix = data.aws_lb.static.arn_suffix
	root_domain = module.constants.aex_za_client_facing_domain
	target_port = 443
	targets = data.aws_instances.portal.ids
	vpc_id = module.constants_env.vpc_id
	target_protocol = "HTTPS"
	health_check_protocol = "HTTPS"
	target_group_name = "api-client-prepaid"
	providers = {
		aws.dns = aws.operations
	}
	response_time_threshold = 1
}

module preprod_api_client_prepaid_route {
	source = "../../../../../../modules/aws/static-load-balancer/modules/route"
	listener_arn = data.aws_lb_listener.static_443.arn
	domain = "preprod.api.client-prepaid.${module.constants.aex_za_client_facing_domain}"
	lb_dns = data.aws_lb.static.dns_name
	lb_arn_suffix = data.aws_lb.static.arn_suffix
	root_domain = module.constants.aex_za_client_facing_domain
	target_port = 443
	targets = data.aws_instances.portal.ids
	vpc_id = module.constants_env.vpc_id
	target_protocol = "HTTPS"
	health_check_protocol = "HTTPS"
	target_group_name = "api-client-prepaid"
	providers = {
		aws.dns = aws.operations
	}
	response_time_threshold = 1
}

module stage_portal_dark_fiber_africa_route {
	source = "../../../../../../modules/aws/static-load-balancer/modules/route"
	listener_arn = "arn:aws:elasticloadbalancing:af-south-1:039129132867:listener/app/portal-stage-1/0803cc74bf1425bd/857a74ba0500d698"
	domain = "stage.darkfibreafrica.dev.${module.constants.aex_za_client_facing_domain}"
	lb_dns = "portal-stage-1-1702388107.af-south-1.elb.amazonaws.com"
	lb_arn_suffix = data.aws_lb.static.arn_suffix
	root_domain = module.constants.aex_za_client_facing_domain
	target_port = 443
	targets = data.aws_instances.portal.ids
	vpc_id = module.constants_env.vpc_id
	target_protocol = "HTTPS"
	health_check_protocol = "HTTPS"
	target_group_name = "stage-portal"
	providers = {
		aws.dns = aws.operations
	}
	response_time_threshold = 1
}

module preprod_portal_dark_fiber_africa_route {
	source = "../../../../../../modules/aws/static-load-balancer/modules/route"
	listener_arn = "arn:aws:elasticloadbalancing:af-south-1:039129132867:listener/app/portal-preprod-1/8eb0cd4a99ae0084/3035c7733fe8b197"
	domain = "preprod.darkfibreafrica.dev.${module.constants.aex_za_client_facing_domain}"
	lb_dns = "portal-preprod-1-1751018412.af-south-1.elb.amazonaws.com"
	lb_arn_suffix = data.aws_lb.static.arn_suffix
	root_domain = module.constants.aex_za_client_facing_domain
	target_port = 443
	targets = data.aws_instances.portal.ids
	vpc_id = module.constants_env.vpc_id
	target_protocol = "HTTPS"
	health_check_protocol = "HTTPS"
	target_group_name = "preprod-portal"
	providers = {
		aws.dns = aws.operations
	}
	response_time_threshold = 1
}


