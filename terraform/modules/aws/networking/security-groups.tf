//========================
resource aws_security_group elb_public_security_group {
	vpc_id = var.vpc_id

	name = "${var.cluster_fqn}_elb_public_security_group"
	description = "${var.cluster_fqn}_elb_public_security_group"

	tags = {
		Name = "${var.cluster_fqn}_elb_public_security_group"
	}
}

module egress_public_all {
	source = "./modules/egress-all"
	security_group_id = aws_security_group.elb_public_security_group.id
}

//========================
resource aws_security_group portal_private_security_group {
	vpc_id = var.vpc_id

	name = "${var.cluster_fqn}_portal_private_security_group"
	description = "${var.cluster_fqn}_portal_private_security_group"

	tags = {
		Name = "${var.cluster_fqn}_portal_private_security_group"
		"aex/vpn/pingable" = true
		"aex/operations/pingable" = true
	}
}

module egress_portal_all {
	source = "./modules/egress-all"
	security_group_id = aws_security_group.portal_private_security_group.id
}

module ingress_portal_private_vpc_ping {
	source = "./modules/ingress-ping"
	security_group_id = aws_security_group.portal_private_security_group.id
	cidr = [var.vpc_cidr]
}

module ingress_portal_private_siem {
	source = "./modules/ingress-siem"
	security_group_id = aws_security_group.portal_private_security_group.id
}

//========================
resource aws_security_group nms_services_private_security_group {
	vpc_id = var.vpc_id

	name = "${var.cluster_fqn}_nms_services_private_security_group"
	description = "${var.cluster_fqn}_nms_services_private_security_group"

	tags = {
		Name = "${var.cluster_fqn}_nms_services_private_security_group"
		"aex/vpn/pingable" = true
		"aex/operations/pingable" = true
		"aex/operations/prtg" = true
		"aex/vpn/ssh" = true
		"aex/operations/ssh" = true
		"aex/nms" = true
	}
}

module egress_nms_all {
	source = "./modules/egress-all"
	security_group_id = aws_security_group.nms_services_private_security_group.id
}

module ingress_nms_ssh_all {
	source = "./modules/ingress-ssh-all"
	count = var.nms_is_public ? 1 : 0
	security_group_id = aws_security_group.nms_services_private_security_group.id
}

module ingress_nms_siem {
	source = "./modules/ingress-siem"
	security_group_id = aws_security_group.nms_services_private_security_group.id
}

resource aws_security_group_rule nms_radius {
	count = signum(length(var.radius_cidrs))
	type = "ingress"
	description = "RADIUS BRAS"
	from_port = 1812
	to_port = 1813
	protocol = "udp"
	cidr_blocks = var.radius_cidrs
	security_group_id = aws_security_group.nms_services_private_security_group.id
}

resource aws_security_group_rule nms_from_vpc {
	type = "ingress"
	from_port = 0
	to_port = 0
	protocol = -1
	description = "All subnets that can access NMS"
	cidr_blocks = concat([var.integration_cidr], [for s in concat([
		aws_subnet.services_private_a,
		// from the public - because nms is public facing
		aws_subnet.public_a,
		aws_subnet.public_b,
		aws_subnet.windows_services_private_a,
		aws_subnet.eks_private_a,
	], var.is_multi_az ? [
		aws_subnet.services_private_b[0],
		aws_subnet.windows_services_private_b[0],
		aws_subnet.eks_private_b[0],
	] : []) : s.cidr_block])
	security_group_id = aws_security_group.nms_services_private_security_group.id
}

//========================
resource aws_security_group static_services_private_security_group {
	vpc_id = var.vpc_id

	name = "${var.cluster_fqn}_static_services_private_security_group"
	description = "${var.cluster_fqn}_static_services_private_security_group"

	tags = {
		Name = "${var.cluster_fqn}_static_services_private_security_group"
		"aex/service" = true
		"aex/operations" = true
		"aex/vpn/pingable" = true
		"aex/operations/pingable" = true
		"aex/operations/prtg" = true
		"aex/vpn/ssh" = true
		"aex/operations/ssh" = true
		"aex/vpn/rdp" = true
	}
}

module ingress_static_services_ssh_all {
	source = "./modules/ingress-ssh-all"
	count = var.api_is_public ? 1 : 0
	security_group_id = aws_security_group.static_services_private_security_group.id
}

module ingress_static_services_rdp_all {
	count = var.portal_is_public ? 1 : 0
	source = "./modules/ingress-public"
	security_group_id = aws_security_group.static_services_private_security_group.id
	description = "TO DELETE, temporary public RDP"
	ports = [3389]
}

module egress_static_services_all {
	source = "./modules/egress-all"
	security_group_id = aws_security_group.static_services_private_security_group.id
}

module ingress_static_services_vpn {
	source = "./modules/ingress-vpc"
	security_group_id = aws_security_group.static_services_private_security_group.id
	vpc_cidr = var.vpc_cidr
}

module ingress_static_services_siem {
	source = "./modules/ingress-siem"
	security_group_id = aws_security_group.static_services_private_security_group.id
}

//========================
resource aws_security_group db_private_security_group {
	vpc_id = var.vpc_id

	name = "${var.cluster_fqn}_db_private_security_group"
	description = "${var.cluster_fqn}_db_private_security_group"

	tags = {
		Name = "${var.cluster_fqn}_db_private_security_group"
		"aex/data" = true
	}
}

module egress_db_all {
	source = "./modules/egress-all"
	security_group_id = aws_security_group.db_private_security_group.id
}

resource aws_security_group_rule db_from_vpn {
	type = "ingress"
	from_port = 0
	to_port = 0
	protocol = -1
	description = "All subnets that can access data"
	cidr_blocks = concat([var.integration_cidr], [for s in concat([
		aws_subnet.private_a,
		aws_subnet.services_private_a,
		aws_subnet.windows_services_private_a,
		aws_subnet.eks_private_a,
	], var.is_multi_az ? [
		aws_subnet.private_b[0],
		aws_subnet.services_private_b[0],
		aws_subnet.windows_services_private_b[0],
		aws_subnet.eks_private_b[0],
	] : []) : s.cidr_block])
	security_group_id = aws_security_group.db_private_security_group.id
}

//========================
resource aws_security_group elasticsearch_private_security_group {
	vpc_id = var.vpc_id

	name = "${var.cluster_fqn}_elasticsearch_private_security_group"
	description = "${var.cluster_fqn}_elasticsearch_private_security_group"

	tags = {
		Name = "${var.cluster_fqn}_elasticsearch_private_security_group"
	}
}

module egress_elastic_all {
	source = "./modules/egress-all"
	security_group_id = aws_security_group.elasticsearch_private_security_group.id
}

//========================
resource aws_security_group eks_private_security_group {
	vpc_id = var.vpc_id

	name = "${var.cluster_fqn}_eks_private_security_group"
	description = "${var.cluster_fqn}_eks_private_security_group"

	tags = {
		Name = "${var.cluster_fqn}_eks_private_security_group"
	}
}

module egress_eks_all {
	source = "./modules/egress-all"
	security_group_id = aws_security_group.eks_private_security_group.id
}
