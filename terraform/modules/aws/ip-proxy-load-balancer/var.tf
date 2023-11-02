variable purpose {
	description = "The purpose for the IP Proxy"
	type = string
}

variable vpc_id {
	description = "VPC Id"
	type = string
}

variable cluster_fqn {
	type = string
	description = "used to construct the domain name, along with domain_purpose"
}


variable subnets {
	type = set(string)
	description = "List of subnets the resource should be connected to"
}


variable internal {
	type = bool
	description = "Should the load balancer be internal or external facing"
	default = false
}

variable extra_tags {
	type = map(string)
	description = "Tags to apply"
}