locals {
	limit_amount = "600"
	vpc_prefix = "10.184.64"
	vpc_cidr = "${local.vpc_prefix}.0/18"
	cluster_fqn = module.constants_cluster.cluster_name
	integration_cidr = cidrsubnet(local.vpc_cidr, 6, 0)
	k8s_context = module.constants_cluster.aws_profile
	central_gateway = "vumatel-transit"
	cluster_name = module.constants_cluster.cluster_name
}

data aws_dx_gateway transit {
	name = "vumatel-1"
	provider = aws.transit
}

module constants_cluster {
	source = "../modules/constants"
}

module constants {
	source = "../../../modules/aws/constants"
}
