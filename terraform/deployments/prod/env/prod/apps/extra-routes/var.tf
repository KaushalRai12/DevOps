locals {
	error_actions = [module.constants_env.sns_error_arn]
	warning_actions = [module.constants_env.sns_warning_arn]
	root_domain = module.constants.aex_legacy_domain
	cluster_fqn = module.constants_env.cluster_fqn
}

module constants {
	source = "../../../../../../modules/aws/constants"
}

module constants_env {
	source = "../../modules/constants"
}

module constants_cluster {
	source = "../../../../modules/constants"
}

data aws_lb static {
	name = "${replace(module.constants_env.cluster_fqn, "_", "-")}-svc"
}

data aws_lb external_ip {
	name = "${replace(module.constants_env.cluster_fqn, "_", "-")}-ip-external"
}

data aws_lb_listener static_443 {
	load_balancer_arn = data.aws_lb.static.arn
	port = 443
}

data aws_lb_listener external_ip_443 {
	load_balancer_arn = data.aws_lb.external_ip.arn
	port = 443
}

data aws_instances api {
	instance_tags = {
		"aex/purpose" = "api"
	}
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
}

data aws_instances portal {
	instance_tags = {
		"aex/purpose" = "portal"
	}
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
}
