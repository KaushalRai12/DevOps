module this {
	source = "../../../../../../modules/apps/requestd"
	cluster_name = module.constants_cluster.cluster_shortname
	cluster_env = module.constants_env.cluster_env
	storage_capacity = "20Gi"
	kube_context = module.constants_env.k8s_context
	root_domain = module.constants.aex_i11l_systems_domain
	providers = {
		aws.dns = aws.operations
	}
}
