# constants_cluster
locals {
	cluster_name = "operations"
	aws_profile = "vumatel-${local.cluster_name}"
	logs_bucket = "vumatel-${local.cluster_name}-logs"
	kube_context = local.aws_profile
}

output cluster_name {
	value = local.cluster_name
}

output cluster_shortname {
	value = "ops"
}

output aws_profile {
	value = local.aws_profile
}

output aws_region {
	value = "af-south-1"
}

output logs_bucket {
	value = local.logs_bucket
}

output kube_context {
	value = local.kube_context
}

data aws_vpc vpc {
	tags = {
		Name : "${local.cluster_name}_vpc"
	}
}

output vpc_id {
	value = data.aws_vpc.vpc.id
}

output vpc_cidr {
	value = data.aws_vpc.vpc.cidr_block
}
