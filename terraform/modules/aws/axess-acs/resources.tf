resource aws_security_group axess_acs {
	vpc_id = var.vpc_id

	name = "axess-acs-lab"
	description = "Axess ACS Lab"

	tags = {
		Name = "axess_acs-lab"
		"aex/vpn/pingable" = true
	}
}

module egress_all {
	source = "../networking/modules/egress-all"
	security_group_id = aws_security_group.axess_acs.id
}

module ingress_cpe {
	source = "../networking/modules/ingress-generic"
	security_group_id = aws_security_group.axess_acs.id
	cidr = ["196.211.33.160/29"]
	ports = ["7547", "9675", "9677", "8678"]
	description = "CPE Ingress"
}

module ingress_ui {
	source = "../networking/modules/ingress-web-public"
	security_group_id = aws_security_group.axess_acs.id
	description = "Management interface"
}

module ingress_ssh {
	source = "../networking/modules/ingress-ssh-all"
	security_group_id = aws_security_group.axess_acs.id
}

module axess_acs_lab_server {
	source = "../static-servers/modules/static-server"
	ami = "ami-08f1789bf92f29508"
	instance_type = "c5.xlarge"
	key_name = "acs"
	subnet_ids = var.subnet_ids
	server_name = "axess-acs"
	security_group_ids = [var.security_group_id, aws_security_group.axess_acs.id]
	servers_per_function = 1
	root_block_size = 150
	cluster_name = var.cluster_name
	cluster_env = var.cluster_env
	requires_elastic_ip = true
	patch_group = null
	custom_monitoring = false
	providers = {
		aws.dns = aws.dns
	}
}
