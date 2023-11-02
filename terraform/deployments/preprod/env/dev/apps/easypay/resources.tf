module easypay {
	source = "../../../../../../modules/apps/easypay"
	name_prefix = "dev"
	vpc_id = module.constants_env.vpc_id
	k8s_namespace = "aex-${local.env}"
	is_multi_zone = false
}
