module server {
	source = "../../../../../../modules/apps/jump-box"
	vpc_id = module.constants_env.vpc_id
	cluster_name = module.constants_cluster.cluster_shortname
	internal_root_domain = module.constants.aex_i11l_infrastructure_domain
	public_root_domain = module.constants.aex_i11l_systems_domain
	providers = {
		aws.dns = aws.operations
	}
}
