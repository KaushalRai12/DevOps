module k8s_ingress {
	source = "../../../../../../modules/aws/k8s-ingress"
	cluster_name = module.constants_cluster.cluster_shortname
	k8s_namespace = var.env
	shared_services = var.shared_services
	internal_services = var.internal_services
	external_services = var.external_services
	// note: some services are never called from outside k8s, such as:
	// snmp-service
	internal_root_domain = module.constants.aex_i11l_systems_domain
	external_root_domain = module.constants.aex_i11l_client_facing_domain

	logs_bucket = var.logs_bucket
	vpc_id = module.constants_env.vpc_id
	aws_profile = "vumatel-preprod"
	providers = {
		aws.dns = aws.dns
	}
}

module k8s_ingress_app {
	source = "../../../../../../modules/aws/k8s-ingress"
	cluster_name = module.constants_cluster.cluster_shortname
	k8s_namespace = var.env
	purpose = "app"
	external_service_map = concat(local.client_interface_routes, local.installer_routes)
	logs_bucket = var.logs_bucket
	vpc_id = module.constants_env.vpc_id
	internal_root_domain = module.constants.aex_i11l_systems_domain
	external_root_domain = module.constants.aex_i11l_client_facing_domain
	aws_profile = "vumatel-preprod"
	providers = {
		aws.dns = aws.dns
	}
}

module static_servers {
	source = "../../../../../../modules/aws/static-servers"
	services_private_subnet_ids = data.aws_subnets.services.ids
	services_private_sg_id = data.aws_security_group.services.id
	nms_subnet_ids = data.aws_subnets.nms.ids
	nms_sg_id = data.aws_security_group.nms.id
	windows_portal_subnet_ids = data.aws_subnets.portal.ids
	windows_portal_instance_type = "t3.medium"
	windows_portal_ami = var.windows_portal_ami
	api_server_ami = var.api_server_ami
	api_server_instance_type = var.api_server_instance_type
	nms_server_ami = var.nms_server_ami
	nms_server_instance_type = "t3.medium"
	devops_server_ami = var.devops_server_ami
	api_server_root_block_size = 35
	encrypt_volumes = var.encrypt_volumes
	servers_per_function = 1
	worker_servers = 0
	efs_id = var.efs_id
	bootstrap_storage = true
	cluster_name = module.constants_cluster.cluster_shortname
	cluster_env = var.env
	custom_monitoring_windows = true
	root_domain = module.constants.aex_i11l_infrastructure_domain
	providers = {
		aws.dns = aws.dns
	}
}

module static_load_balancer {
	source = "../../../../../../modules/aws/static-load-balancer"
	cluster_fqn = module.constants_cluster.cluster_shortname
	load_balancer_name = "svc-${var.env}"
	vpc_id = module.constants_env.vpc_id
	api_server_ids = module.static_servers.api_server_ids
	nms_server_ids = module.static_servers.nms_server_ids
	subnets = data.aws_subnets.public.ids
	default_certificate_arn = data.aws_acm_certificate.default.arn
	cluster_name = module.constants_cluster.cluster_shortname
	domain_environment = var.env
	security_group_id = data.aws_security_group.lb.id
	logs_bucket = var.logs_bucket
	external_root_domain = module.constants.aex_i11l_client_facing_domain
	internal_root_domain = module.constants.aex_i11l_internal_api_domain
	providers = {
		aws.dns = aws.dns
	}
}

module portal_load_balancer {
	source = "../../../../../../modules/aws/portal-route/modules/portal_load_balancer"
	vpc_id = module.constants_env.vpc_id
	portal_server_ids = module.static_servers.portal_server_ids
	domain_environment = var.env
	cluster_name = module.constants_cluster.cluster_shortname
	access_log_bucket = var.logs_bucket
	security_group_id = data.aws_security_group.lb.id
	cluster_fqn = module.constants_env.cluster_fqn
	default_certificate_arn = data.aws_acm_certificate.default.arn
	subnet_ids = data.aws_subnets.public.ids
	portal_names = var.portal_names
	external_root_domain = module.constants.aex_i11l_client_facing_domain
	providers = {
		aws.dns = aws.dns
	}
}
