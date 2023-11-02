resource aws_route_table public_route_table {
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_public_route_table"
		"aex/vpn/routable" : true
		"aex/operations/routable" : true
		"aex/public" : true
		"aex/load-balancers" : true
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
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_private_a_route_table"
		"aex/vpn/routable" : true
		"aex/operations/routable" : true
		"aex/public" : false
		"aex/load-balancers" : true
	}
}

resource aws_route integration_eks_a_to_bng_nat {
	for_each = toset(module.constants.vumatel_bng_cidrs)
	route_table_id = aws_route_table.eks_integration_private_a_route_table.id
	destination_cidr_block = each.value
	nat_gateway_id = aws_nat_gateway.private_nat_a[0].id
}

resource aws_route integration_eks_b_to_bng_nat {
	for_each = toset(module.constants.vumatel_bng_cidrs)
	route_table_id = aws_route_table.eks_integration_private_b_route_table[0].id
	destination_cidr_block = each.value
	nat_gateway_id = aws_nat_gateway.private_nat_b[0].id
}

resource aws_route private_a_nat {
	route_table_id = aws_route_table.private_a_route_table.id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = aws_nat_gateway.nat_a.id
}

resource aws_route_table_association private_subnet_a {
	subnet_id = aws_subnet.private_a.id
	route_table_id = aws_route_table.private_a_route_table.id
}

# One option. But this exposes ALL the routes from the gateway (in this case Vumatel) to the subnet
# resource aws_vpn_gateway_route_propagation private_subnet_a {
# 	for_each = toset(data.aws_route_tables.routable.ids)
# 	route_table_id = each.value
# 	vpn_gateway_id = var.vpn_gateway_id
# }

# Rather add static routes for the routable subnets
resource aws_route vpn_routing {
	for_each = toset(data.aws_route_tables.routable.ids)
	route_table_id = each.value
	gateway_id = var.vpn_gateway_id
	destination_cidr_block = module.constants.vumatel_remote_vpn_cidr
}

resource aws_route_table private_b_route_table {
	count = var.is_multi_az ? 1 : 0
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_private_b_route_table"
		"aex/vpn/routable" : true
		"aex/operations/routable" : true
		"aex/public" : false
		"aex/load-balancers" : true
	}
}

resource aws_route private_b_nat {
	count = var.is_multi_az ? 1 : 0
	route_table_id = aws_route_table.private_b_route_table[0].id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = var.shared_nat_gateway ? aws_nat_gateway.nat_a.id : aws_nat_gateway.nat_b[0].id
}

resource aws_route_table_association private_subnet_b {
	count = var.is_multi_az ? 1 : 0
	subnet_id = aws_subnet.private_b[0].id
	route_table_id = aws_route_table.private_b_route_table[0].id
}

resource aws_route_table nms_private_a_route_table {
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_nms_private_a_route_table"
		"aex/vpn/routable" : true
		"aex/operations/routable" : true
		"aex/data-access" : true
		"aex/integration" : true
		"aex/eks" : false
	}
}

resource aws_route nms_a {
	route_table_id = aws_route_table.nms_private_a_route_table.id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = var.nms_is_public ? null : aws_nat_gateway.nat_a.id
	gateway_id = var.nms_is_public ? aws_internet_gateway.internet_gateway.id : null
}

resource aws_route_table_association nms_private_subnet_a {
	subnet_id = aws_subnet.nms_private_a.id
	route_table_id = aws_route_table.nms_private_a_route_table.id
}

resource aws_vpn_gateway_route_propagation nms_private_subnet_a {
	route_table_id = aws_route_table.nms_private_a_route_table.id
	vpn_gateway_id = var.vpn_gateway_id
}

resource aws_route_table nms_private_b_route_table {
	count = var.is_multi_az ? 1 : 0
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_nms_private_b_route_table"
		"aex/vpn/routable" : true
		"aex/operations/routable" : true
		"aex/data-access" : true
		"aex/integration" : true
		"aex/eks" : false
	}
}

resource aws_route nms_b {
	count = var.is_multi_az ? 1 : 0
	route_table_id = aws_route_table.nms_private_b_route_table[0].id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = var.nms_is_public ? null : var.shared_nat_gateway ? aws_nat_gateway.nat_a.id : aws_nat_gateway.nat_b[0].id
	gateway_id = var.nms_is_public ? aws_internet_gateway.internet_gateway.id : null
}

resource aws_route_table_association nms_private_subnet_b {
	count = var.is_multi_az ? 1 : 0
	subnet_id = aws_subnet.nms_private_b[0].id
	route_table_id = aws_route_table.nms_private_b_route_table[0].id
}

resource aws_vpn_gateway_route_propagation nms_private_subnet_b {
	count = var.is_multi_az ? 1 : 0
	route_table_id = aws_route_table.nms_private_b_route_table[0].id
	vpn_gateway_id = var.vpn_gateway_id
}

resource aws_route_table eks_private_a_route_table {
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_eks_private_a_route_table"
		"aex/vpn/routable" : true
		"aex/operations/routable" : true
		"aex/operations/can-reach-others" : true
		"aex/data-access" : true
		"aex/eks" : true
		"aex/integration" : false
	}
}

resource aws_route eks_a {
	route_table_id = aws_route_table.eks_private_a_route_table.id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = aws_nat_gateway.nat_a.id
}

resource aws_route_table_association eks_private_subnet_a {
	subnet_id = aws_subnet.eks_private_a.id
	route_table_id = aws_route_table.eks_private_a_route_table.id
}

resource aws_route_table eks_private_b_route_table {
	count = var.is_multi_az ? 1 : 0
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_eks_private_b_route_table"
		"aex/vpn/routable" : true
		"aex/operations/routable" : true
		"aex/operations/can-reach-others" : true
		"aex/data-access" : true
		"aex/eks" : true
		"aex/integration" : false
	}
}

resource aws_route eks_b {
	count = var.is_multi_az ? 1 : 0
	route_table_id = aws_route_table.eks_private_b_route_table[0].id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = var.shared_nat_gateway ? aws_nat_gateway.nat_a.id : aws_nat_gateway.nat_b[0].id
}

resource aws_route_table_association eks_private_subnet_b {
	count = var.is_multi_az ? 1 : 0
	subnet_id = aws_subnet.eks_private_b[0].id
	route_table_id = aws_route_table.eks_private_b_route_table[0].id
}

resource aws_route_table eks_integration_private_a_route_table {
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_eks_integration_private_a_route_table"
		"aex/operations/routable" : true
		"aex/data-access" : true
		"aex/integration" : true
		"aex/eks" : true
	}
}

resource aws_route eks_integration_a {
	route_table_id = aws_route_table.eks_integration_private_a_route_table.id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = aws_nat_gateway.nat_a.id
}

resource aws_route_table_association eks_integration_private_subnet_a {
	subnet_id = aws_subnet.eks_integration_private_a.id
	route_table_id = aws_route_table.eks_integration_private_a_route_table.id
}

resource aws_vpn_gateway_route_propagation eks_integration_private_subnet_a {
	route_table_id = aws_route_table.eks_integration_private_a_route_table.id
	vpn_gateway_id = var.vpn_gateway_id
}

resource aws_route_table eks_integration_private_b_route_table {
	count = var.is_multi_az ? 1 : 0
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_eks_integration_private_b_route_table"
		"aex/data-access" : true
		"aex/integration" : true
		"aex/eks" : true
	}
}

resource aws_route eks_integration_b {
	count = var.is_multi_az ? 1 : 0
	route_table_id = aws_route_table.eks_integration_private_b_route_table[0].id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = var.shared_nat_gateway ? aws_nat_gateway.nat_a.id : aws_nat_gateway.nat_b[0].id
}

resource aws_route_table_association eks_integration_private_subnet_b {
	count = var.is_multi_az ? 1 : 0
	subnet_id = aws_subnet.eks_integration_private_b[0].id
	route_table_id = aws_route_table.eks_integration_private_b_route_table[0].id
}

resource aws_vpn_gateway_route_propagation eks_integration_private_subnet_b {
	count = var.is_multi_az ? 1 : 0
	route_table_id = aws_route_table.eks_integration_private_b_route_table[0].id
	vpn_gateway_id = var.vpn_gateway_id
}

resource aws_route_table services_private_a_route_table {
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_services_private_a_route_table"
		"aex/vpn/routable" : true
		"aex/operations/routable" : true
		"aex/operations/can-reach-others" : true
		"aex/data-access" : true
		"aex/services" : true
		"aex/windows" : false
	}
}

resource aws_route services_a {
	route_table_id = aws_route_table.services_private_a_route_table.id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = var.api_is_public ? null : aws_nat_gateway.nat_a.id
	gateway_id = var.api_is_public ? aws_internet_gateway.internet_gateway.id : null
}

resource aws_route_table_association services_private_subnet_a {
	subnet_id = aws_subnet.services_private_a.id
	route_table_id = aws_route_table.services_private_a_route_table.id
}

resource aws_route_table services_private_b_route_table {
	count = var.is_multi_az ? 1 : 0
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_services_private_b_route_table"
		"aex/vpn/routable" : true
		"aex/operations/routable" : true
		"aex/operations/can-reach-others" : true
		"aex/data-access" : true
		"aex/services" : true
		"aex/windows" : false
	}
}

resource aws_route services_b {
	count = var.is_multi_az ? 1 : 0
	route_table_id = aws_route_table.services_private_b_route_table[0].id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = var.api_is_public ? null : var.shared_nat_gateway ? aws_nat_gateway.nat_a.id : aws_nat_gateway.nat_b[0].id
	gateway_id = var.api_is_public ? aws_internet_gateway.internet_gateway.id : null
}

resource aws_route_table_association services_private_subnet_b {
	count = var.is_multi_az ? 1 : 0
	subnet_id = aws_subnet.services_private_b[0].id
	route_table_id = aws_route_table.services_private_b_route_table[0].id
}

resource aws_route_table windows_services_private_a_route_table {
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_windows_services_private_a_route_table"
		"aex/vpn/routable" : true
		"aex/operations/routable" : true
		"aex/data-access" : true
		"aex/services" : true
		"aex/windows" : true
	}
}

resource aws_route windows_a {
	route_table_id = aws_route_table.windows_services_private_a_route_table.id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = var.portal_is_public ? null : aws_nat_gateway.nat_a.id
	gateway_id = var.portal_is_public ? aws_internet_gateway.internet_gateway.id : null
}

resource aws_route_table_association windows_services_private_subnet_a {
	subnet_id = aws_subnet.windows_services_private_a.id
	route_table_id = aws_route_table.windows_services_private_a_route_table.id
}

resource aws_route_table windows_services_private_b_route_table {
	count = var.is_multi_az ? 1 : 0
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_windows_services_private_b_route_table"
		"aex/vpn/routable" : true
		"aex/operations/routable" : true
		"aex/data-access" : true
		"aex/services" : true
		"aex/windows" : true
	}
}

resource aws_route windows_b {
	count = var.is_multi_az ? 1 : 0
	route_table_id = aws_route_table.windows_services_private_b_route_table[0].id
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = var.portal_is_public ? null : var.shared_nat_gateway ? aws_nat_gateway.nat_a.id : aws_nat_gateway.nat_b[0].id
	gateway_id = var.portal_is_public ? aws_internet_gateway.internet_gateway.id : null
}

resource aws_route_table_association windows_services_private_subnet_b {
	count = var.is_multi_az ? 1 : 0
	subnet_id = aws_subnet.windows_services_private_b[0].id
	route_table_id = aws_route_table.windows_services_private_b_route_table[0].id
}

resource aws_route_table data_private_a_route_table {
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_data_private_a_route_table"
		"aex/vpn/routable" : true
		"aex/operations/routable" : true
		"aex/data" : true
	}
}

resource aws_route_table_association data_private_subnet_a {
	subnet_id = aws_subnet.data_private_a.id
	route_table_id = aws_route_table.data_private_a_route_table.id
}

resource aws_route_table data_private_b_route_table {
	vpc_id = var.vpc_id

	tags = {
		Name : "${var.cluster_fqn}_data_private_b_route_table"
		"aex/vpn/routable" : true
		"aex/operations/routable" : true
		"aex/data" : true
	}
}

resource aws_route_table_association data_private_subnet_b {
	subnet_id = aws_subnet.data_private_b.id
	route_table_id = aws_route_table.data_private_b_route_table.id
}
