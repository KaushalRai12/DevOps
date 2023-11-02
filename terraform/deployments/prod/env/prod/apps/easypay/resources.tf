module easypay {
	source = "../../../../../../modules/apps/easypay"
	name_prefix = "prod"
	vpc_id = module.constants_env.vpc_id
	k8s_namespace = "aex-${local.env}"
	is_multi_zone = false
	easypay_cidr = "192.168.200.0/24"
}
