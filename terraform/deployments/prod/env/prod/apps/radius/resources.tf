module this {
	source = "../../../../../../modules/apps/radius"
	vpc_id = module.constants_env.vpc_id
	domain_name = "vumatel"
	instance_name = "vumatel"
	namespace = "aex-prod"
	subnets = data.aws_subnets.target.ids
	cluster_fqn = module.constants_env.cluster_fqn
	providers = {
		aws.dns = aws.vumatel_operations
	}

}
