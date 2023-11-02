module constants_env {
	source = "../../modules/constants/"
}

data aws_vpc vpc {
	id = module.constants_env.vpc_id
}

data aws_subnets all {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
}
