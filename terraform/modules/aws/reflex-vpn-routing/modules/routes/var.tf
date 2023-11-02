variable vpc_id {
	type = string
}

variable transit_gateway_id {
	type = string
}

variable route_table_id {
	type = string
}

variable extra_vpn_routes {
	description = "Extra CIDRs to send through the VPN"
	type = set(string)
	default = []
}

module constants {
	source = "../../../constants"
}
