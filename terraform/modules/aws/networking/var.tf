module constants {
	source = "../constants"
}

variable cluster_fqn {
	type = string
}

variable vpc_id {
	type = string
}

variable vpc_cidr {
	type = string
}

variable integration_cidr {
	type = string
}

variable vpn_gateway_id {
	type = string
}

variable nms_is_public {
	type = bool
	default = false
}

variable api_is_public {
	type = bool
	default = false
}

variable portal_is_public {
	type = bool
	default = false
}

variable radius_cidrs {
	type = list(string)
	default = []
}

variable has_private_nat {
	description = "Set to true to enable private NAT gateways"
	default = false
}

variable is_multi_az {
	description = "Set to false to have multi-AZ coverage"
	default = true
}

variable shared_nat_gateway {
	description = "Set to true to share a NAT gateway between AZs"
	default = false
}

//================ data
data aws_region current {}

data aws_availability_zones available {
	state = "available"
}

data aws_caller_identity account {}

locals {
	cluster_fqn = replace(var.cluster_fqn, "_", "-")
}

data aws_route_tables routable {
	vpc_id = var.vpc_id

	filter {
		name   = "tag:aex/vpn/routable"
		values = ["true"]
	}
}

//================== Outputs

output db_subnet_ids {
	value = [aws_subnet.data_private_a.id, aws_subnet.data_private_b.id]
}

output db_security_group_id {
	value = aws_security_group.db_private_security_group.id
}

output static_services_subnet_ids {
	value = concat([aws_subnet.services_private_a.id], var.is_multi_az ? [aws_subnet.services_private_b[0].id] : [])
}

output static_services_security_group_id {
	value = aws_security_group.static_services_private_security_group.id
}

output nms_subnet_ids {
	value = concat([aws_subnet.nms_private_a.id], var.is_multi_az ? [aws_subnet.nms_private_b[0].id] : [])
}

output nms_security_group_id {
	value = aws_security_group.nms_services_private_security_group.id
}

output windows_subnet_ids {
	value = concat([aws_subnet.windows_services_private_a.id], var.is_multi_az ? [aws_subnet.windows_services_private_b[0].id] : [])
}

output windows_security_group_id {
	value = aws_security_group.static_services_private_security_group.id
}

output eks_node_subnet_ids {
	value = concat([aws_subnet.eks_private_a.id], var.is_multi_az ? [aws_subnet.eks_private_b[0].id] : [])
}

output eks_node_security_group_id {
	value = aws_security_group.eks_private_security_group.id
}

output eks_integration_security_group_id {
	value = aws_security_group.eks_private_security_group.id
}

output eks_integration_node_subnet_ids {
	value = concat([aws_subnet.eks_integration_private_a.id], var.is_multi_az ? [aws_subnet.eks_integration_private_b[0].id] : [])
}

output eks_security_group_id {
	value = aws_security_group.eks_private_security_group.id
}

output public_subnet_ids {
  value = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output private_subnet_ids {
  value = concat([aws_subnet.private_a.id], var.is_multi_az ? [aws_subnet.private_b[0].id] : [])
}

output db_subnet_group_name {
	value = aws_db_subnet_group.db_subnet_group.name
}
