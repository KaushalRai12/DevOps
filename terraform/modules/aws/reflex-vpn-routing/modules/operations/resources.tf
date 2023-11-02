// Add a route to each route table to reach operations
resource aws_route route {
	for_each = toset(data.aws_route_tables.routable.ids)
	route_table_id = each.value
	destination_cidr_block = module.constants.operations_cidr
	transit_gateway_id = var.transit_gateway_id
}

// Add yourself to operations route tables
resource aws_route route_from_ops {
	provider = aws.operations
	for_each = toset(data.aws_route_tables.can_route_from_ops.ids)
	route_table_id = each.value
	destination_cidr_block = var.vpc_cidr
	transit_gateway_id = data.aws_ec2_transit_gateway.central.id
}

resource aws_security_group_rule ssh {
	for_each = toset(data.aws_security_groups.ssh.ids)
	security_group_id = each.value
	type = "ingress"
	description = "Operations SSH"
	from_port = 22
	to_port = 22
	protocol = "tcp"
	cidr_blocks = [module.constants.operations_cidr]
}

resource aws_security_group_rule win_rm {
	for_each = toset(data.aws_security_groups.win_rm.ids)
	security_group_id = each.value
	type = "ingress"
	description = "Operations WinRM"
	from_port = 5985
	to_port = 5986
	protocol = "tcp"
	cidr_blocks = [module.constants.operations_cidr]
}

resource aws_security_group_rule ping {
	for_each = toset(data.aws_security_groups.pingable.ids)
	security_group_id = each.value
	type = "ingress"
	description = "Operations Ping"
	from_port = 8
	to_port = 0
	protocol = "icmp"
	cidr_blocks = [module.constants.operations_cidr]
}
