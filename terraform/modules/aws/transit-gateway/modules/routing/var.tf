variable subnet_ids {
	type = set(string)
}

variable vpc_cidr {
	type = string
}

variable vpc_id {
	type = string
}

variable transit_gateway_id {
	type = string
}

variable extra_vpn_routes {
	description = "Extra CIDRs to send through the VPN"
	type = set(string)
	default = []
}

locals {
	central_gateway = "vumatel-transit"
}

data aws_route_table linked {
	for_each = var.subnet_ids
	filter {
		name = "association.subnet-id"
		values = [each.value]
	}
}

data aws_vpc transit {
	provider = aws.transit
	filter {
		name = "tag:Name"
		values = ["transit_vpc"]
	}
}

data aws_ec2_transit_gateway central {
	provider = aws.transit
	filter {
		name = "tag:Name"
		values = [local.central_gateway]
	}
}

data aws_security_groups ssh {
	filter {
		name   = "tag:aex/vpn/ssh"
		values = ["true"]
	}

	filter {
		name   = "vpc-id"
		values = [var.vpc_id]
	}
}

data aws_security_groups pingable {
	filter {
		name   = "tag:aex/vpn/pingable"
		values = ["true"]
	}

	filter {
		name   = "vpc-id"
		values = [var.vpc_id]
	}
}

data aws_route_tables routable {
	vpc_id = var.vpc_id

	filter {
		name   = "tag:aex/vpn/routable"
		values = ["true"]
	}
}

data aws_route_table transit_gateway {
	for_each = var.subnet_ids
	subnet_id = each.value
}

