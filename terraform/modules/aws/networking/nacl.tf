resource aws_network_acl nacl_public {
	vpc_id = var.vpc_id

	egress {
		protocol = "-1"
		rule_no = 100
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 0
		to_port = 0
	}

	ingress {
		protocol = "-1"
		rule_no = 100
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 0
		to_port = 0
	}

	subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]

	tags = {
		Name = "${var.cluster_fqn}_public_nacl"
	}
}

# Create Private NACL
resource aws_network_acl nacl_private {
	vpc_id = var.vpc_id

	egress {
		protocol = "-1"
		rule_no = 100
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 0
		to_port = 0
	}

	ingress {
		protocol = "-1"
		rule_no = 100
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 0
		to_port = 0
	}

	subnet_ids = concat(
		[
			aws_subnet.eks_private_a.id,
			aws_subnet.eks_integration_private_a.id,
			aws_subnet.services_private_a.id,
			aws_subnet.windows_services_private_a.id,
			aws_subnet.data_private_a.id,
			aws_subnet.nms_private_a.id,
			aws_subnet.private_a.id,
			aws_subnet.data_private_b.id,
		],
		var.is_multi_az ? [
			aws_subnet.eks_private_b[0].id,
			aws_subnet.eks_integration_private_b[0].id,
			aws_subnet.services_private_b[0].id,
			aws_subnet.windows_services_private_b[0].id,
			aws_subnet.nms_private_b[0].id,
			aws_subnet.private_b[0].id,
		] : [])

	tags = {
		Name = "${var.cluster_fqn}_private_nacl"
	}
}
