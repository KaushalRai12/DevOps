resource aws_security_group efs {
	count = var.deploy_efs ? 1 : 0
	vpc_id = var.vpc_id

	name = "${var.cluster_fqn}_efs_private_security_group"
	description = "${var.cluster_fqn}_efs_private_security_group"

	tags = {
		Name = "${var.cluster_fqn}_efs_private_security_group"
	}

	lifecycle {
		create_before_destroy = true
	}
}

module ingress_static_services_vpn {
	count = var.deploy_efs ? 1 : 0
	source = "../networking/modules/egress-all"
	security_group_id = aws_security_group.efs[0].id
}

resource aws_security_group_rule static_services {
	for_each = var.deploy_efs ? var.efs_allowed_source_group_ids : []
	type = "ingress"
	description = "all static services"
	from_port = 2049
	to_port = 2049
	protocol = "tcp"
	security_group_id = aws_security_group.efs[0].id
	source_security_group_id = each.value
}


resource aws_efs_file_system efs_file_system {
	count = var.deploy_efs ? 1 : 0
	creation_token = "${var.cluster_fqn}_efs"
	performance_mode = "generalPurpose"
	throughput_mode = "bursting"
	encrypted = "true"

	tags = {
		Name = "${var.cluster_fqn}_efs"
	}
}

resource aws_efs_mount_target efs_mount_target {
	for_each = var.deploy_efs ? var.efs_subnet_ids : []
	file_system_id = aws_efs_file_system.efs_file_system[0].id
	security_groups = [aws_security_group.efs[0].id]
	subnet_id = each.value
}
