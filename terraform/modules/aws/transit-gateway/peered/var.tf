variable vpc_id {
	type = string
}

variable vpc_cidr {
	type = string
}

variable cluster_fqn {
	type = string
}

variable subnet_ids {
	type = set(string)
}

variable route_table {
	type = string
	default = "prod"
}

variable extra_vpn_routes {
	description = "Extra CIDRs to send through the VPN"
	type = set(string)
	default = []
}

locals {
	central_gateway = "vumatel-transit"
	cluster_fqn = replace(var.cluster_fqn, "_", "-")
}

module constants {
	source = "../../constants"
}

data aws_caller_identity account {}

data aws_caller_identity transit {
	provider = aws.transit
}

data aws_region transit {
	provider = aws.transit
}

output transit_gateway_id {
	value = aws_ec2_transit_gateway.local.id
}

data aws_ec2_transit_gateway central {
	provider = aws.transit
	filter {
		name = "tag:Name"
		values = [local.central_gateway]
	}
}

data aws_ec2_transit_gateway_route_table transit {
	provider = aws.transit
	filter {
		name   = "tag:Name"
		values = ["transit"]
	}
}

data aws_ec2_transit_gateway_route_table operations {
	provider = aws.transit
	filter {
		name   = "tag:Name"
		values = ["operations"]
	}
}
