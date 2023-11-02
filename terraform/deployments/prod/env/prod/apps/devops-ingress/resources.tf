module ingress {
	source = "../../../../../../modules/aws/k8s-ingress"
	vpc_id = module.constants_env.vpc_id
	cluster_name = module.constants_cluster.cluster_name
	k8s_namespace = "devops"
	internal_services = local.internal_services
	internal_service_map = local.internal_service_map
	external_services = local.external_services
	external_service_map = local.external_service_map
	internal_service_secure_default = true
	domain_prefix = ""
	purpose = module.constants_env.cluster_env
	logs_bucket = module.constants_env.logs_bucket
	providers = {
		aws.dns = aws.dns
	}
}
