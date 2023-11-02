resource aws_eip eip_a {
	vpc = true
	tags = {
		Name = "${local.cluster_fqn}_nat_a_eip"
	}
}

resource aws_nat_gateway nat_a {
	depends_on = [
		aws_eip.eip_a
	]
	allocation_id = aws_eip.eip_a.id
	subnet_id = aws_subnet.public_a.id
	tags = {
		Name = "${local.cluster_fqn}_nat_a"
	}
}

resource aws_internet_gateway internet_gateway {
	vpc_id = module.vpc.vpc_id
	tags = {
		Name = "${local.cluster_fqn}_internet_gateway"
	}
}
