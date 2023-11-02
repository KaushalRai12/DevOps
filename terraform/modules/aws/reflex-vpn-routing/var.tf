variable transit_gateway_id {
	type = string
}

variable vpc_id {
	type = string
}

variable extra_vpn_routes {
	description = "Extra CIDRs to send through the VPN"
	type = set(string)
	default = []
}

module constants {
	source = "../constants"
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

data aws_security_groups prtg {
	filter {
		name   = "tag:aex/operations/prtg"
		values = ["true"]
	}

	filter {
		name   = "vpc-id"
		values = [var.vpc_id]
	}
}

data aws_security_groups rdp {
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
		name   = "tag:aex/vpn/routable"
		values = ["true"]
	}
}
