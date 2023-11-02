module this {
	source = "../../../../../../modules/apps/requestd"
	cluster_name = module.constants_cluster.cluster_shortname
	cluster_env = module.constants_env.cluster_env
	storage_capacity = "300Gi"
	kube_context = local.kube_context
	providers = {
		aws.dns = aws.vumatel_operations
	}
}
