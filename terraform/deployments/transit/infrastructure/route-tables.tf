resource aws_route_table public_route_table {
	vpc_id = module.vpc.vpc_id

	tags = {
		Name = "${local.cluster_fqn}_public_route_table"
	}
}

resource aws_route public_gateway {
	route_table_id = aws_route_table.public_route_table.id
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.internet_gateway.id
}

resource aws_route_table_association public_subnet_a {
	subnet_id = aws_subnet.public_a.id
	route_table_id = aws_route_table.public_route_table.id
}
resource aws_route_table_association public_subnet_b {
	subnet_id = aws_subnet.public_b.id
	route_table_id = aws_route_table.public_route_table.id
}

resource aws_route_table private_a_route_table {
	vpc_id = module.vpc.vpc_id

	tags = {
		Name = "${local.cluster_fqn}_private_a_route_table"
	}
}

resource aws_route private_a_nat {
	route_table_id = aws_route_table.private_a_route_table.id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = aws_nat_gateway.nat_a.id
}

resource aws_route_table_association private_subnet-a {
	subnet_id = aws_subnet.private_a.id
	route_table_id = aws_route_table.private_a_route_table.id
}

resource aws_route_table private_b_route_table {
	vpc_id = module.vpc.vpc_id

	tags = {
		Name = "${local.cluster_fqn}_private_b_route_table"
	}
}

resource aws_route private_b_nat {
	route_table_id = aws_route_table.private_b_route_table.id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = aws_nat_gateway.nat_a.id
}

resource aws_route_table_association private_subnet_b {
	subnet_id = aws_subnet.private_b.id
	route_table_id = aws_route_table.private_b_route_table.id
}
