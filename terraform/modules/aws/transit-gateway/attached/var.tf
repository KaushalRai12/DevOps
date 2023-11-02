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

variable add_ops_route {
	description = "Set to false to suppress adding the ops routing - specifically if you are ops"
	type = bool
	default = true
}

variable extra_vpn_routes {
	description = "Extra CIDRs to send through the VPN"
	type = set(string)
	default = []
}

locals {
	central_gateway = "vumatel-transit"
	transit_vpc = "transit_vpc"
	cluster_fqn = replace(var.cluster_fqn, "_", "-")
}

data aws_caller_identity account {}

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

output transit_gateway_id {
	value = data.aws_ec2_transit_gateway.central.id
}

/*
output central_route_table_id {
	description = "Id of the centrally created route table"
	value = module.route_table.route_table_id
}
*/
