module k8s_ingress {
	source = "../../../../../../modules/aws/k8s-ingress"
	cluster_name = module.constants_cluster.cluster_shortname
	k8s_namespace = local.env
	shared_services = local.shared_services
	internal_services = local.internal_services
	external_services = local.external_services
	// note: some services are never called from outside k8s, such as:
	// snmp-service
	internal_root_domain = module.constants.aex_i11l_systems_domain
	external_root_domain = module.constants.aex_i11l_client_facing_domain

	logs_bucket = module.constants_env.logs_bucket
	vpc_id = module.constants_env.vpc_id
	aws_profile = "vumatel-preprod"
	providers = {
		aws.dns = aws.dns
	}
}




