module server {
	source = "../../aws/static-servers/modules/static-server"
	ami = coalesce(var.ami_id, module.ami.ubuntu_20_04_x86)
	instance_type = "t3.nano"
	key_name = "jump-box"
	server_name = "jump"
	security_group_ids = concat(data.aws_security_groups.this.ids, [aws_security_group.jump_box.id])
	subnet_ids = data.aws_subnets.this.ids
	servers_per_function = 1
	root_block_size = 20
	cluster_name = var.cluster_name
	cluster_env = "prod"
	patch_group = "ubuntu"
	custom_monitoring = false
	requires_elastic_ip = true
	root_domain = var.internal_root_domain
	providers = {
		aws.dns = aws.dns
	}
}

resource aws_security_group jump_box {
	vpc_id = var.vpc_id

	name = "jump-box"
	description = "Security group for Linux jump boxes"

	tags = {
		Name = "jump-box"
	}
}

module all_ssh_ingress {
	source = "../../aws/networking/modules/ingress-ssh-all"
	security_group_id = aws_security_group.jump_box.id
}

resource aws_route53_record a_record {
	zone_id = data.aws_route53_zone.public_zone.zone_id
	name = "jump.${var.cluster_name}"
	type = "A"
	ttl = 600
	records = module.server.public_ips
	provider = aws.dns
}
