variable attachment_id {
	description = "Id for the transit gateway attachment"
	type = string
}

variable cluster_fqn {
	description = "Cluster fully qualified name"
	type = string
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

data aws_ec2_transit_gateway central {
	provider = aws.transit
	filter {
		name = "tag:Name"
		values = [local.central_gateway]
	}
}

data aws_vpc transit {
	provider = aws.transit
	tags = {
		Name : local.transit_vpc
	}
}

data aws_ec2_transit_gateway_vpc_attachment transit {
	provider = aws.transit
	filter {
		name = "vpc-id"
		values = [data.aws_vpc.transit.id]
	}
}

# data aws_ec2_transit_gateway_vpn_attachment transit {
# 	provider = aws.transit
# 	transit_gateway_id = data.aws_ec2_transit_gateway.central.id
# 	vpn_connection_id = module.constants.transit_vpn_id_rosebank
# }

data aws_ec2_transit_gateway_vpc_attachment ops {
	provider = aws.transit
	filter {
		name = "tag:Name"
		values = ["operations"]
	}
}

module constants {
	source = "../../../constants"
}

output route_table_id {
	value = aws_ec2_transit_gateway_route_table.this.id
}
