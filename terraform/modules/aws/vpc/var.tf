variable cluster_fqn {
	type = string
}

variable vpc_cidr {
	type = string
}

variable actual_vpc_cidr {
	type = string
	description = "legacy - for those VPCs that have not yet been migrated to /16 ranges (e.g. gcpud dev & national-us prod)"
	default = null
}

variable logs_bucket_arn {
	type = string
	description = "ARN of the bucket to be used for logs"
}

output vpc_id {
	value = aws_vpc.vpc.id
}

output vpn_gateway_id {
	value = aws_vpn_gateway.vpc_gateway.id
}

output vpc_cidr_block {
	value = aws_vpc.vpc.cidr_block
}

locals {
	actual_vpc_cidr = var.actual_vpc_cidr != null ? var.actual_vpc_cidr : var.vpc_cidr
}
