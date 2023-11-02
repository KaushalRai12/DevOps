resource aws_eip eip_a {
	vpc = true
	tags = {
		Name = "${var.cluster_fqn}_nat_a_eip"
	}
}

resource aws_nat_gateway nat_a {
	allocation_id = aws_eip.eip_a.id
	subnet_id = aws_subnet.public_a.id
	tags = {
		Name = "${var.cluster_fqn}_nat_a"
	}
}

resource aws_eip eip_b {
	count = var.is_multi_az ? 1 : 0
	vpc = true
	tags = {
		Name = "${var.cluster_fqn}_nat_b_eip"
	}
}

resource aws_nat_gateway nat_b {
	count = var.is_multi_az && !var.shared_nat_gateway ? 1 : 0
	allocation_id = aws_eip.eip_b[0].id
	subnet_id = aws_subnet.public_b.id
	tags = {
		Name = "${var.cluster_fqn}_nat_b"
	}
}

resource aws_internet_gateway internet_gateway {
	vpc_id = var.vpc_id
	tags = {
		Name = "${var.cluster_fqn}_internet_gateway"
	}
}

# In the NMS subnets, since the k8s subnets definitely need the functionaly
# If you need then NMS subnets to use the NAT, you'll need to move it into
# another subnet with access to the network
resource aws_nat_gateway private_nat_a {
	count = var.has_private_nat ? 1 : 0
	# allocation_id = aws_eip.eip_a.id
	connectivity_type = "private"
	subnet_id = aws_subnet.nms_private_a.id
	tags = {
		Name = "${var.cluster_fqn}_private_nat_a"
	}
}

resource aws_nat_gateway private_nat_b {
	count = var.is_multi_az && var.has_private_nat && !var.shared_nat_gateway ? 1 : 0
	# allocation_id = aws_eip.eip_b[0].id
	connectivity_type = "private"
	subnet_id = aws_subnet.nms_private_b[0].id
	tags = {
		Name = "${var.cluster_fqn}_private_nat_b"
	}
}
