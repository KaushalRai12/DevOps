locals {
	root_domain = module.constants.aex_za_public_domain
	domain_name = "gitlab.vumaex.net"
	cluster_fqn = module.constants_cluster.cluster_name
	registration_token = jsondecode(data.aws_secretsmanager_secret_version.gitlab.secret_string)["registration-token"]
}

data aws_security_group services {
	filter {
		name = "vpc-id"
		values = [module.constants_cluster.vpc_id]
	}
	tags = {
		"aex/service" : true
	}
}

data aws_subnet services {
	vpc_id = module.constants_cluster.vpc_id
	filter {
		name = "tag:aex/operations"
		values = ["true"]
	}
	filter {
		name = "tag:aex/az"
		values = ["a"]
	}
}

data aws_subnets public {
	filter {
		name = "vpc-id"
		values = [module.constants_cluster.vpc_id]
	}
	tags = {
		"aex/public": true
		"aex/az": "a"
	}
}

data aws_subnet_ids operations {
	vpc_id = module.constants_cluster.vpc_id
	tags = {
		"aex/operations": true
	}
}

data aws_route53_zone zone {
	name = module.constants.aex_i11l_systems_domain
}

module constants {
	source = "../../../../modules/aws/constants"
}

module constants_cluster {
	source = "../../modules/constants"
}

data aws_secretsmanager_secret_version gitlab {
	secret_id = "gitlab"
}

