# constants_cluster
locals {
	cluster_name = "preprod"
	cluster_env = "dev"
	cluster_fqn = "${local.cluster_name}-${local.cluster_env}"
	aws_profile = "vumatel-${local.cluster_name}"
	aws_region = "af-south-1"
	logs_bucket = "vumatel-${local.cluster_name}-logs"
	k8s_context = "vumatel-${local.cluster_name}-${local.cluster_env}"
	# TODO Move these to a more global setup
	rosebank_nms_routes = []
	vumtal_nms_routes = [
		"10.88.10.0/24",
		"10.42.0.0/16",
	]
}

output cluster_name {
	value = local.cluster_name
}

output cluster_shortname {
	value = "dev"
}

output aws_profile {
	value = local.aws_profile
}

output aws_region {
	value = local.aws_region
}

output aws_preferred_az {
	value = "${local.aws_region}a"
}

output logs_bucket {
	value = local.logs_bucket
}

data aws_vpc vpc {
	tags = {
		Name : "${local.cluster_name}_${local.cluster_env}_vpc"
	}
}

output rosebank_nms_routes {
	value = local.rosebank_nms_routes
}

output vpc_id {
	value = data.aws_vpc.vpc.id
}

output vpc_cidr {
	value = data.aws_vpc.vpc.cidr_block
}

output k8s_context {
	value = local.k8s_context
}
