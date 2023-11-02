variable gateway_id {
	type = string
}

variable customer_gateway_id {
	type = string
}

variable name {
	type = string
}

variable static_routes {
	type = set(string)
	default = []
}

variable force_static_routes {
	description = "Force static routes, even if the list is empty"
	type = bool
	default = false
}

variable is_transit {
	type = bool
	default = false
}

variable encryption_algorithms  {
	type = set(string)
	default = ["AES256", "AES128-GCM-16", "AES256-GCM-16"]
}

variable hash_algorithms {
	type = set(string)
	default = ["SHA2-256", "SHA2-384", "SHA2-512"]
}

variable ike_versions {
	type = set(string)
	default = []
}

variable phase1_dh_group_numbers {
	type = set(string)
	default = []
}

variable transit_gateway_route_table_id {
	type = string
	default = null
}

locals {
	vpn_static_routes = var.is_transit ? [] : var.static_routes
	transit_static_routes = var.is_transit ? var.static_routes: []
}

output transit_gateway_attachment_id {
	value = aws_vpn_connection.vpn.transit_gateway_attachment_id
}
