resource aws_route transit {
	for_each = var.routes
	route_table_id = var.route_table_id
	destination_cidr_block = each.value
	transit_gateway_id = var.transit_gateway_id
}

