resource aws_ec2_transit_gateway local {
	tags = {
		Name = "${local.central_gateway}-peer"
	}
}

resource aws_ec2_transit_gateway_vpc_attachment this {
	subnet_ids = var.subnet_ids

	transit_gateway_id = aws_ec2_transit_gateway.local.id
	vpc_id = var.vpc_id

	tags = {
		Name = replace(var.cluster_fqn, "_", "-")
		Side = "Creator"
	}
}

resource aws_ec2_transit_gateway_peering_attachment this {
	peer_account_id = data.aws_caller_identity.transit.account_id
	peer_region = data.aws_region.transit.name
	peer_transit_gateway_id = data.aws_ec2_transit_gateway.central.id
	transit_gateway_id = aws_ec2_transit_gateway.local.id

	tags = {
		Name = local.central_gateway
	}
}

resource aws_ec2_transit_gateway_peering_attachment_accepter this {
	provider = aws.transit
	transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this.id

	tags = {
		Name = replace(var.cluster_fqn, "_", "-")
		Side = "Accepter"
	}
}

module route_table {
	source = "../modules/route-table"
	attachment_id = aws_ec2_transit_gateway_peering_attachment.this.id
	cluster_fqn = local.cluster_fqn
	extra_vpn_routes = var.extra_vpn_routes
	providers = {
		aws.transit = aws.transit
	}
}

// Add VPN & operations routes to this route table
resource aws_ec2_transit_gateway_route local {
	for_each = toset(concat(tolist(module.constants.aex_vpn_cidrs), [module.constants.operations_cidr]))
	destination_cidr_block = each.value
	transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this.id
	transit_gateway_route_table_id = aws_ec2_transit_gateway.local.association_default_route_table_id
}

// Add this VPC CIDR to the transit route table
resource aws_ec2_transit_gateway_route transit {
	provider = aws.transit
	destination_cidr_block = var.vpc_cidr
	transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this.id
	transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.transit.id
}

// Add this VPC CIDR to this route table
resource aws_ec2_transit_gateway_route this {
	provider = aws.transit
	destination_cidr_block = var.vpc_cidr
	transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this.id
	transit_gateway_route_table_id = module.route_table.route_table_id
}

// Add myself to the ops route table - ops must be able to route to me
resource aws_ec2_transit_gateway_route myself_to_ops {
	provider = aws.transit
	destination_cidr_block = var.vpc_cidr
	transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.this.id
	transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.operations.id
}

module routing {
	source = "../modules/routing"
	subnet_ids = var.subnet_ids
	transit_gateway_id = aws_ec2_transit_gateway.local.id
	vpc_cidr = var.vpc_cidr
	vpc_id = var.vpc_id
	extra_vpn_routes = var.extra_vpn_routes
	providers = {
		aws.transit = aws.transit
	}
}
