# constants_env (dev)
locals {
	cluster_env = "dev"
	cluster_fqn = "${module.constants_cluster.cluster_name}-${local.cluster_env}"
	k8s_context = "vumatel-${module.constants_cluster.cluster_name}-${local.cluster_env}"
	logs_bucket = "vumatel-${local.cluster_fqn}-logs"
	vpc_cidr_prefix = "10.184"
	vpc_cidr = "${local.vpc_cidr_prefix}.128.0/18"
	integration_cidr = "${local.vpc_cidr_prefix}.128.0/24"
}

module constants_cluster {
	source = "../../../../modules/constants"
}

data aws_vpc vpc {
	tags = {
		Name : "${replace(local.cluster_fqn, "-", "_")}_vpc"
	}
}

output vpc_id {
	value = data.aws_vpc.vpc.id
}

output cluster_fqn {
	value = local.cluster_fqn
}

output cluster_env {
	value = local.cluster_env
}

output k8s_context {
	value = local.k8s_context
}

output logs_bucket {
	value = local.logs_bucket
}

output vpc_cidr {
	value = local.vpc_cidr
}

output integration_cidr {
	value = local.integration_cidr
}
