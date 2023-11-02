# constants_cluster
locals {
	cluster_name = "central"
	aws_profile = "vumatel-${local.cluster_name}"
	logs_bucket = "vumatel-${local.cluster_name}-logs"
}

output cluster_name {
	value = local.cluster_name
}

output cluster_shortname {
	value = local.cluster_name
}

output aws_profile {
	value = local.aws_profile
}

output aws_region {
	value = "af-south-1"
}

output alternate_aws_region {
	value = "eu-west-1"
}

output logs_bucket {
	value = local.logs_bucket
}
