resource aws_route route {
	for_each = setunion(module.constants.aex_vpn_cidrs, var.extra_vpn_routes)
	route_table_id = var.route_table_id
	destination_cidr_block = each.value
	transit_gateway_id = var.transit_gateway_id
}
