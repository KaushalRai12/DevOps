variable cluster_fqn {
	type = string
}

variable openid_arn {
	type = string
}

variable openid_url {
	type = string
}

module general_constants {
	source = "../../../general/modules/constants"
}

data aws_iam_policy lb_controller {
	name = module.general_constants.eks_lb_controller_policy
}
