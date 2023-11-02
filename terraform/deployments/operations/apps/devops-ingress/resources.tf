module ingress {
	source = "../../../../modules/aws/k8s-ingress"
	cluster_name = module.constants_cluster.cluster_shortname
	k8s_namespace = "devops"
	external_services = local.external_services
	external_service_map = local.external_service_map
	internal_services = local.internal_services
	internal_service_map = local.internal_service_map
	internal_service_secure_default = true
	domain_prefix = ""
	logs_bucket = module.constants_cluster.logs_bucket
	// Temporary, until SQ issue is sorted
	ssl_policy = "ELBSecurityPolicy-FS-2018-06"
	vpc_id = module.constants_cluster.vpc_id
	internal_root_domain = module.constants.aex_i11l_systems_domain
	external_root_domain = module.constants.aex_i11l_systems_domain # Using systems since its Ops
	providers = {
		aws.dns = aws.operations
	}
}
