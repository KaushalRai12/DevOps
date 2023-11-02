variable instance_name {
	type = string
}

variable namespace {
	type = string
}

variable domain_name {
	type = string
}

variable subnets {
	description = "List of subnets in which to deploy - for RADIUS, usually the integration subnets"
	type = list(string)
}

variable ip_addresses {
	description = "List of IP addresses - must be one for each subnet. If not specified, will auto-allocate."
	type = list(string)
	default = []
}

variable cluster_fqn {
	description = "cluster fully qualified name"
	type = string
}

variable vpc_id {
	description = "VPC ID"
	type = string
}

variable ingress_cidrs {
	description = "Optional extra CIDRs for access into RADIUS - for e.g. from client DCs"
	type = list(string)
	default = []
}

locals {
	internal_domain = "vumaex.net"
}

data aws_security_group eks {
	filter {
		name = "vpc-id"
		values = [var.vpc_id]
	}
	tags = {
		"aws:eks:cluster-name" : var.cluster_fqn
		"kubernetes.io/cluster/${var.cluster_fqn}" : "owned"
	}
}

module constants {
	source = "../../aws/constants"
}
