# https://medium.com/@heycasey/creating-a-transit-gateway-6e3df814a07a

locals {
	gateway_name = "vumatel-operations"
}

resource aws_ec2_transit_gateway operations {
	tags = {
		Name = local.gateway_name
	}
}

resource aws_ram_resource_share operations {
	name = local.gateway_name

	tags = {
		Name = local.gateway_name
	}
}

resource aws_ram_resource_association operations {
	resource_arn = aws_ec2_transit_gateway.operations.arn
	resource_share_arn = aws_ram_resource_share.operations.arn
}

resource aws_ec2_transit_gateway_route_table operations {
	transit_gateway_id = aws_ec2_transit_gateway.operations.id
	tags = {
		Name = local.cluster_fqn
	}
}

# Attach the Operations Account VPC to the Transit Gateway
resource aws_ec2_transit_gateway_vpc_attachment operations {
	# depends_on = [aws_ram_principal_association.operations]
	subnet_ids = module.networking.private_subnet_ids
	transit_gateway_id = aws_ec2_transit_gateway.operations.id
	vpc_id = module.vpc.vpc_id

	tags = {
		Name = local.gateway_name
		Side = "Creator"
	}
}

resource aws_ec2_transit_gateway_route_table_propagation operations {
	transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.operations.id
	transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.operations.id
}

# Does not seem to be necessary
# resource aws_ec2_transit_gateway_vpc_attachment_accepter operations {
# 	transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.operations.id

# 	tags = {
# 		Name = local.gateway_name
# 		Side = "Accepter"
# 	}
# }
