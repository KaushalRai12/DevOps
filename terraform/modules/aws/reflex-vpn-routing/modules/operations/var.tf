variable transit_gateway_id {
	type = string
}

variable vpc_id {
	type = string
}

variable vpc_cidr {
	type = string
}

module constants {
	source = "../../../constants"
}

data aws_security_groups pingable {
	filter {
		name = "tag:aex/operations/pingable"
		values = ["true"]
	}

	filter {
		name = "vpc-id"
		values = [var.vpc_id]
	}
}

data aws_security_groups ssh {
	filter {
		name = "tag:aex/operations/ssh"
		values = ["true"]
	}

	filter {
		name = "vpc-id"
		values = [var.vpc_id]
	}
}

data aws_security_groups win_rm {
	filter {
		name   = "tag:aex/vpn/rdp"
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
		name = "tag:aex/operations/routable"
		values = ["true"]
	}
}

data aws_vpc ops {
	provider = aws.operations
	filter {
		name = "tag:Name"
		values = ["operations_vpc"]
	}
}

data aws_route_tables can_route_from_ops {
	provider = aws.operations
	vpc_id = data.aws_vpc.ops.id

	filter {
		name = "tag:aex/operations/can-reach-others"
		values = ["true"]
	}
}

data aws_ec2_transit_gateway central {
	provider = aws.transit
	filter {
		name = "tag:Name"
		values = ["vumatel-transit"]
	}
}

