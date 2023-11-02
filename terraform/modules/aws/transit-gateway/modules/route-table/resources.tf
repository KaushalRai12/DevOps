resource aws_ec2_transit_gateway_route_table this {
	provider = aws.transit
	transit_gateway_id = data.aws_ec2_transit_gateway.central.id
	tags = {
		Name = local.cluster_fqn
	}
}

// Associate the new route table to this account's VPC
resource aws_ec2_transit_gateway_route_table_association this {
	provider = aws.transit
	transit_gateway_attachment_id = var.attachment_id
	transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}

// Add a VPN route for AEx remote and office CIDRs
# No longer needed
# resource aws_ec2_transit_gateway_route transit_vpn {
# 	provider = aws.transit
# 	for_each = module.constants.aex_vpn_cidrs
# 	destination_cidr_block = each.value
# 	transit_gateway_attachment_id = data.aws_ec2_transit_gateway_vpn_attachment.transit.id
# 	transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
# }

// Add a VPN route for each extra VPN route
# No longer needed
# resource aws_ec2_transit_gateway_route extra_vpn {
# 	provider = aws.transit
# 	for_each = var.extra_vpn_routes
# 	destination_cidr_block = each.value
# 	transit_gateway_attachment_id = data.aws_ec2_transit_gateway_vpn_attachment.transit.id
# 	transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
# }

// Propagate the transit VPC routes to this route table
resource aws_ec2_transit_gateway_route_table_propagation transit {
	provider = aws.transit
	transit_gateway_attachment_id = data.aws_ec2_transit_gateway_vpc_attachment.transit.id
	transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}

// Propagate the operations VPC routing to MY route table
resource aws_ec2_transit_gateway_route_table_propagation this_ops {
	count = var.add_ops_route ? 1 : 0
	provider = aws.transit
	transit_gateway_attachment_id = data.aws_ec2_transit_gateway_vpc_attachment.ops.id
	transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}
