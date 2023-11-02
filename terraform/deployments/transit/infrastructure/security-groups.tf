resource aws_security_group public_security_group {
	vpc_id = module.vpc.vpc_id

	name = "${local.cluster_fqn}_public_security_group"
	description = "${local.cluster_fqn}_public_security_group"

	tags = {
		Name = "${local.cluster_fqn}_public_security_group"
	}
}

module public_egress_all {
	source = "../../../modules/aws/networking/modules/egress-all"
	security_group_id = aws_security_group.public_security_group.id
}

resource aws_security_group private_security_group {
	vpc_id = module.vpc.vpc_id

	name = "${local.cluster_fqn}_private_security_group"
	description = "${local.cluster_fqn}_private_security_group"

	tags = {
		Name = "${local.cluster_fqn}_private_security_group"
	}
}

module private_egress_all {
	source = "../../../modules/aws/networking/modules/egress-all"
	security_group_id = aws_security_group.private_security_group.id
}
