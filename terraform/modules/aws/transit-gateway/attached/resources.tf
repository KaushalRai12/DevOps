data aws_ram_resource_share transit {
	provider = aws.transit
	name = "reflex-transit-gateway"
	resource_owner = "SELF"
}

resource aws_ram_principal_association main {
	provider = aws.transit
	principal = data.aws_caller_identity.account.account_id
	resource_share_arn = data.aws_ram_resource_share.transit.id
}

resource aws_ec2_transit_gateway_vpc_attachment reflex {
	subnet_ids = var.subnet_ids

	transit_gateway_id = data.aws_ec2_transit_gateway.central.id
	vpc_id = var.vpc_id

	tags = {
		Name = local.central_gateway
		Side = "Creator"
	}

	depends_on = [aws_ram_principal_association.main]
}

resource aws_ec2_transit_gateway_vpc_attachment_accepter main {
	provider = aws.transit
	transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.reflex.id
	transit_gateway_default_route_table_association = false
	transit_gateway_default_route_table_propagation = false

	tags = {
		Name = local.cluster_fqn
		Side = "Accepter"
	}
}

module route_table {
	source = "../modules/route-table"
	attachment_id = aws_ec2_transit_gateway_vpc_attachment.reflex.id
	cluster_fqn = local.cluster_fqn
	add_ops_route = var.add_ops_route
	extra_vpn_routes = var.extra_vpn_routes
	providers = {
		aws.transit = aws.transit
	}
}

// Propagate this VPC CIDR to the route table
resource aws_ec2_transit_gateway_route_table_propagation this {
	provider = aws.transit
	transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.reflex.id
	transit_gateway_route_table_id = module.route_table.route_table_id
}

// Propagate myself to the ops route table - ops must be able to route to me
resource aws_ec2_transit_gateway_route_table_propagation ops {
	provider = aws.transit
	count = var.add_ops_route ? 1 : 0
	transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.reflex.id
	transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.operations.id
}

// Propagate this VPC CIDR to the transit route table
resource aws_ec2_transit_gateway_route_table_propagation transit {
	provider = aws.transit
	transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.reflex.id
	transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.transit.id
}

module routing {
	source = "../modules/routing"
	subnet_ids = var.subnet_ids
	transit_gateway_id = data.aws_ec2_transit_gateway.central.id
	vpc_cidr = var.vpc_cidr
	vpc_id = var.vpc_id
	extra_vpn_routes = var.extra_vpn_routes
	providers = {
		aws.transit = aws.transit
	}
}
