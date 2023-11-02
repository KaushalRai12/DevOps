resource aws_subnet nms_private_a {
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.integration_cidr, 3, 2)
	availability_zone = data.aws_availability_zones.available.names[0]
	tags = {
		Name: "${var.cluster_fqn}_nms_private_a_subnet"
		"aex/nms": true
		"aex/integration": true
		"aex/az": "a"
		"aex/data-access": true
	}
}

resource aws_subnet nms_private_b {
	count = var.is_multi_az ? 1 : 0
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.integration_cidr, 3, 6)
	availability_zone = data.aws_availability_zones.available.names[1]
	tags = {
		Name: "${var.cluster_fqn}_nms_private_b_subnet"
		"aex/nms": true
		"aex/integration": true
		"aex/az": "b"
		"aex/data-access": true
	}
}

resource aws_subnet eks_integration_private_a {
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.integration_cidr, 2, 0)
	availability_zone = data.aws_availability_zones.available.names[0]
	tags = {
		Name: "${var.cluster_fqn}_eks_integration_private_a_subnet"
		"aex/eks": true
		"aex/integration": true
		"aex/az": "a"
		"aex/data-access": true
	}
}

resource aws_subnet eks_integration_private_b {
	count = var.is_multi_az ? 1 : 0
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.integration_cidr, 2, 2)
	availability_zone = data.aws_availability_zones.available.names[1]
	tags = {
		Name: "${var.cluster_fqn}_eks_integration_private_b_subnet"
		"aex/eks": true
		"aex/integration": true
		"aex/az": "a"
		"aex/data-access": true
	}
}

resource aws_subnet public_a {
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.vpc_cidr, 6, 8)
	map_public_ip_on_launch = true
	availability_zone = data.aws_availability_zones.available.names[0]
	tags = {
		Name = "${var.cluster_fqn}_public_a_subnet"
		"kubernetes.io/role/elb" = "1"
		"kubernetes.io/cluster/${var.cluster_fqn}" = "shared"
		"aex/public": true
		"aex/az": "a"
	}
}

resource aws_subnet public_b {
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.vpc_cidr, 6, 9)
	map_public_ip_on_launch = true
	availability_zone = data.aws_availability_zones.available.names[1]
	tags = {
		Name = "${var.cluster_fqn}_public_b_subnet"
		"kubernetes.io/role/elb" = "1"
		"kubernetes.io/cluster/${var.cluster_fqn}" = "shared"
		"aex/public": true
		"aex/az": "b"
	}
}

# Create Services Private Subnet
resource aws_subnet services_private_a {
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.vpc_cidr, 6, 10)
	availability_zone = data.aws_availability_zones.available.names[0]
	tags = {
		Name = "${var.cluster_fqn}_services_private_a_subnet"
		"aex/service": true
		"aex/az": "a"
		"aex/data-access": true
	}
}

resource aws_subnet services_private_b {
	count = var.is_multi_az ? 1 : 0
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.vpc_cidr, 6, 11)
	availability_zone = data.aws_availability_zones.available.names[1]
	tags = {
		Name = "${var.cluster_fqn}_services_private_b_subnet"
		"aex/service": true
		"aex/az": "b"
		"aex/data-access": true
	}
}

resource aws_subnet windows_services_private_a {
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.vpc_cidr, 6, 12)
	availability_zone = data.aws_availability_zones.available.names[0]
	tags = {
		Name = "${var.cluster_fqn}_windows_services_private_a_subnet"
		"aex/portal": true
		"aex/az": "a"
		"aex/data-access": true
	}
}

resource aws_subnet windows_services_private_b {
	count = var.is_multi_az ? 1 : 0
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.vpc_cidr, 6, 13)
	availability_zone = data.aws_availability_zones.available.names[1]
	tags = {
		Name = "${var.cluster_fqn}_windows_services_private_b_subnet"
		"aex/portal": true
		"aex/az": "b"
		"aex/data-access": true
	}
}

# Create Data Private Subnet
resource aws_subnet data_private_a {
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.vpc_cidr, 6, 14)
	availability_zone = data.aws_availability_zones.available.names[0]
	tags = {
		Name = "${var.cluster_fqn}_data_private_a_subnet"
		"aex/data": true
		"aex/az": "a"
	}
}

resource aws_subnet data_private_b {
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.vpc_cidr, 6, 15)
	availability_zone = data.aws_availability_zones.available.names[1]
	tags = {
		Name = "${var.cluster_fqn}_data_private_b_subnet"
		"aex/data": true
		"aex/az": "b"
	}
}

# Create Private Subnet
resource aws_subnet private_a {
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.vpc_cidr, 6, 16)
	availability_zone = data.aws_availability_zones.available.names[0]
	tags = {
		Name = "${var.cluster_fqn}_private_a_subnet"
		"aex/operations": true
		"aex/az": "a"
	}
}

resource aws_subnet private_b {
	count = var.is_multi_az ? 1 : 0
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.vpc_cidr, 6, 17)
	availability_zone = data.aws_availability_zones.available.names[1]
	tags = {
		Name = "${var.cluster_fqn}_private_b_subnet"
		"aex/operations": true
		"aex/az": "b"
	}
}

resource aws_subnet eks_private_a {
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.vpc_cidr, 2, 2)
	availability_zone = data.aws_availability_zones.available.names[0]
	tags = {
		Name = "${var.cluster_fqn}_eks_private_a_subnet"
		"kubernetes.io/role/internal-elb" = 1
		"kubernetes.io/cluster/${var.cluster_fqn}" = "shared"
		"aex/eks": true
		"aex/az": "a"
		"aex/data-access": true
	}
}

resource aws_subnet eks_private_b {
	count = var.is_multi_az ? 1 : 0
	vpc_id = var.vpc_id
	cidr_block = cidrsubnet(var.vpc_cidr, 2, 3)
	availability_zone = data.aws_availability_zones.available.names[1]
	tags = {
		Name = "${var.cluster_fqn}_eks_private_b_subnet"
		"kubernetes.io/role/internal-elb" = 1
		"kubernetes.io/cluster/${var.cluster_fqn}" = "shared"
		"aex/eks": true
		"aex/az": "b"
		"aex/data-access": true
	}
}

resource aws_db_subnet_group db_subnet_group {
	name = "${var.cluster_fqn}_db_subnet_group"
	subnet_ids = [aws_subnet.data_private_a.id, aws_subnet.data_private_b.id]

	tags = {
		Name = "${var.cluster_fqn}_db_subnet_group"
	}
}
