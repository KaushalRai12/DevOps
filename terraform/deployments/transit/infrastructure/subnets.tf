resource aws_subnet public_a {
	vpc_id = module.vpc.vpc_id
	cidr_block = cidrsubnet(local.vpc_cidr, 3, 1)
	map_public_ip_on_launch = "true"
	availability_zone = "${data.aws_region.current.name}a"
	tags = {
		Name = "${local.cluster_fqn}_public_a_subnet"
	}
}

resource aws_subnet public_b {
	vpc_id = module.vpc.vpc_id
	cidr_block = cidrsubnet(local.vpc_cidr, 3, 2)
	map_public_ip_on_launch = "true"
	availability_zone = "${data.aws_region.current.name}b"
	tags = {
		Name = "${local.cluster_fqn}_public_b_subnet"
	}
}

resource aws_subnet private_a {
	vpc_id = module.vpc.vpc_id
	cidr_block = cidrsubnet(local.vpc_cidr, 3, 3)
	map_public_ip_on_launch = "false"
	availability_zone = "${data.aws_region.current.name}a"
	tags = {
		Name = "${local.cluster_fqn}_private_a_subnet"
		"aex/routing" = "true"
	}
}

resource aws_subnet private_b {
	vpc_id = module.vpc.vpc_id
	cidr_block = cidrsubnet(local.vpc_cidr, 3, 4)
	map_public_ip_on_launch = "false"
	availability_zone = "${data.aws_region.current.name}b"
	tags = {
		Name = "${local.cluster_fqn}_private_b_subnet"
		"aex/routing" = "true"
	}
}
