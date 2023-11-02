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
	name = "dev-svc-preprod" // to move somewhere
}

data aws_lb_listener static_443 {
	load_balancer_arn = data.aws_lb.static.arn
	port = 443
}

data aws_instances api {
	instance_tags = {
		"aex/purpose" = "api"
		"Name" = "preprod_api_a"
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
