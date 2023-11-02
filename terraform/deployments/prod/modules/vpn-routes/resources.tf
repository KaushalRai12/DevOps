resource aws_route route {
	for_each = module.constants_cluster.vpn_routes
	route_table_id = var.route_table_id
	destination_cidr_block = each.value
	transit_gateway_id = var.transit_gateway_id
}
