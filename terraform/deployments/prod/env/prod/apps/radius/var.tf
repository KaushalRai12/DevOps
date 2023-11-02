
module constants_cluster {
	source = "../../../../modules/constants"
}

module constants_env {
	source = "../../modules/constants"
}


data aws_subnets target {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
	tags = {
		"aex/nms": true
		"aex/az": "a"
	}
}
