module logs {
	source = "../../../../../../modules/aws/elastic-logs"
	elastic_domain = local.elastic_domain
	kibana_domain = local.kibana_domain
	elastic_values = file("${path.module}/templates/elastic-values.yaml")
	kube_context = module.constants_env.k8s_context
	domain_suffix = module.constants_cluster.cluster_name
	aws_profile = module.constants_cluster.aws_profile
	cluster_env = module.constants_env.cluster_env
	eks_cluster_name = "${module.constants_cluster.cluster_name}_${module.constants_env.cluster_env}"
	elastic_version = local.elastic_version
	kibana_version = local.elastic_version
	root_domain = module.constants.aex_i11l_systems_domain
	has_ingress = false
	providers = {
		aws.dns = aws.operations
	}
}
