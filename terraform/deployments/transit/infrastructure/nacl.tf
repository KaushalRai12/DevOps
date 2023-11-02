# Create Public NACL
resource aws_network_acl nacl_public {
	vpc_id = module.vpc.vpc_id

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

	subnet_ids = [
		aws_subnet.public_a.id,
		aws_subnet.public_b.id
	]

	tags = {
		Name = "${local.cluster_fqn}_public_nacl"
	}
}

# Create Private NACL
resource aws_network_acl nacl_private {
	vpc_id = module.vpc.vpc_id

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

	subnet_ids = [
		aws_subnet.private_a.id,
		aws_subnet.private_b.id
	]

	tags = {
		Name = "${local.cluster_fqn}_private_nacl"
	}
}
