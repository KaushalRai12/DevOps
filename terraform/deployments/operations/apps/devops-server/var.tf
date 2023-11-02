locals {
	k8s_context = module.constants_cluster.aws_profile
}

module constants_cluster {
	source = "../../modules/constants"
}

module constants {
	source = "../../../../modules/aws/constants"
}
