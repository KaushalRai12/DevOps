variable cluster_fqn {
	type = string
}

variable cluster_arn {
	type = string
}

variable cluster_url {
	type = string
}

locals {
	namespace = "kube-system"
	service_account_name = "ebs-csi-driver"
}

module general_constants {
	source = "../../../general/modules/constants"
}

data aws_iam_policy ebs_csi {
	name = module.general_constants.ebs_csi_driver_policy
}
