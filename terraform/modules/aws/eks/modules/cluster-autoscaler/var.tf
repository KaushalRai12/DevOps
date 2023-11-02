variable cluster_fqn {
	type = string
}

variable cluster_arn {
	type = string
}

variable cluster_url {
	type = string
}

variable cluster_name {
	type = string
}

locals {
	namespace = "kube-system"
	service_account_name = "cluster-autoscaler"
}

data aws_region current {}

module general_constants {
  source = "../../../general/modules/constants"
}

data aws_iam_policy autoscaler {
	name = module.general_constants.eks_autoscaler_policy
}
