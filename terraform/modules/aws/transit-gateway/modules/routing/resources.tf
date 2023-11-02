// Route to the transit VPC from the linked subnets
resource aws_route transit {
	for_each = var.subnet_ids
	route_table_id = data.aws_route_table.linked[each.value].id
	destination_cidr_block = data.aws_vpc.transit.cidr_block
	transit_gateway_id = var.transit_gateway_id
}

// Create routes to this vpc from the linked subnets in the transit VPC
data aws_ec2_transit_gateway_vpc_attachment transit {
	provider = aws.transit
	filter {
		name   = "vpc-id"
		values = [data.aws_vpc.transit.id]
	}
	// temporary - until the deleted attachment is gone
	filter {
		name = "tag:Name"
		values = ["transit"]
	}
}

data aws_route_table transit {
	provider = aws.transit
	for_each = data.aws_ec2_transit_gateway_vpc_attachment.transit.subnet_ids
	filter {
		name = "association.subnet-id"
		values = [each.value]
	}
}

resource aws_route back_to_me {
	provider = aws.transit
	for_each = data.aws_ec2_transit_gateway_vpc_attachment.transit.subnet_ids
	route_table_id = data.aws_route_table.transit[each.value].id
	destination_cidr_block = var.vpc_cidr
	transit_gateway_id = data.aws_ec2_transit_gateway.central.id
}

resource aws_security_group_rule ping {
	for_each = toset(data.aws_security_groups.pingable.ids)
	security_group_id = each.value
	type = "ingress"
	description = "Transit Ping"
	from_port = 8
	to_port = 0
	protocol = "icmp"
	cidr_blocks = [data.aws_vpc.transit.cidr_block]
}

resource aws_security_group_rule ssh {
	for_each = toset(data.aws_security_groups.ssh.ids)
	security_group_id = each.value
	type = "ingress"
	description = "Transit SSH"
	from_port = 22
	to_port = 22
	protocol = "tcp"
	cidr_blocks = [data.aws_vpc.transit.cidr_block]
}

resource aws_route route {
	for_each = toset(data.aws_route_tables.routable.ids)
	route_table_id = each.value
	destination_cidr_block = data.aws_vpc.transit.cidr_block
	transit_gateway_id = var.transit_gateway_id
}

module transit_route {
	source = "../transit-route"
	for_each = var.subnet_ids
	route_table_id = data.aws_route_table.transit_gateway[each.value].id
	transit_gateway_id = data.aws_ec2_transit_gateway.central.id
	routes = var.extra_vpn_routes
}
