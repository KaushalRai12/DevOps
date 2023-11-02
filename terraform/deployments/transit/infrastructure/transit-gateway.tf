resource aws_ec2_transit_gateway central {
	default_route_table_association = "disable"
	default_route_table_propagation = "disable"

	tags = {
		Name = "vumatel-transit"
	}
}

resource aws_ram_resource_share central {
	name = "reflex-transit-gateway"

	tags = {
		Name = "reflex-transit-gateway"
	}
}

resource aws_ram_resource_association main {
	resource_arn = aws_ec2_transit_gateway.central.arn
	resource_share_arn = aws_ram_resource_share.central.arn
}

resource aws_ec2_transit_gateway_vpc_attachment reflex {
	subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
	transit_gateway_default_route_table_association = false
	transit_gateway_default_route_table_propagation = false


	transit_gateway_id = aws_ec2_transit_gateway.central.id
	vpc_id = module.vpc.vpc_id

	tags = {
		Name = "transit"
	}
}

resource aws_ec2_transit_gateway_route_table transit {
	transit_gateway_id = aws_ec2_transit_gateway.central.id
	tags = {
		Name = local.cluster_fqn
	}
}

// Associate the new route table to this account's VPC
resource aws_ec2_transit_gateway_route_table_association this {
	transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.reflex.id
	transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit.id
}

resource aws_ec2_transit_gateway_route_table_association vpn {
	transit_gateway_attachment_id = module.reflex_vpn.transit_gateway_attachment_id
	transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit.id
}

// Propagate the transit VPC routes to this route table
resource aws_ec2_transit_gateway_route_table_propagation transit {
	transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.reflex.id
	transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit.id
}

