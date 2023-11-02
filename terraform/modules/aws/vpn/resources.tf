resource aws_vpn_connection vpn {
	customer_gateway_id = var.customer_gateway_id
	vpn_gateway_id = var.is_transit ? null : var.gateway_id
	transit_gateway_id = var.is_transit ? var.gateway_id : null
	type = "ipsec.1"
	static_routes_only = var.force_static_routes || length(var.static_routes) > 0
	tunnel1_phase1_encryption_algorithms = var.encryption_algorithms
	tunnel1_phase2_encryption_algorithms = var.encryption_algorithms
	tunnel1_phase1_integrity_algorithms = var.hash_algorithms
	tunnel1_phase2_integrity_algorithms = var.hash_algorithms
	tunnel1_ike_versions = var.ike_versions
	tunnel1_phase1_dh_group_numbers = var.phase1_dh_group_numbers
	tunnel1_phase2_dh_group_numbers = var.phase1_dh_group_numbers

	tunnel2_phase1_encryption_algorithms = var.encryption_algorithms
	tunnel2_phase2_encryption_algorithms = var.encryption_algorithms
	tunnel2_phase1_integrity_algorithms = var.hash_algorithms
	tunnel2_phase2_integrity_algorithms = var.hash_algorithms
	tunnel2_ike_versions = var.ike_versions
	tunnel2_phase1_dh_group_numbers = var.phase1_dh_group_numbers
	tunnel2_phase2_dh_group_numbers = var.phase1_dh_group_numbers

	tags = {
		Name = var.name
	}
}

resource aws_vpn_connection_route vpn_static_routing {
	for_each = local.vpn_static_routes
	destination_cidr_block = each.value
	vpn_connection_id = aws_vpn_connection.vpn.id
}

resource aws_ec2_transit_gateway_route route {
	for_each = local.transit_static_routes
	destination_cidr_block = each.value
	transit_gateway_attachment_id = aws_vpn_connection.vpn.transit_gateway_attachment_id
	transit_gateway_route_table_id = var.transit_gateway_route_table_id
}

output vpn_id {
	value = aws_vpn_connection.vpn.id
}
