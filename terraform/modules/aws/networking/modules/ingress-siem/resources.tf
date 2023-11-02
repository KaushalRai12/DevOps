module tcp_rule {
	source = "../ingress-generic"
	ports = [1514, 1515, 55000]
	cidr = [module.constants.aex_siem_server_cidr]
	protocol = "tcp"
	description = "SIEM agent"
	security_group_id = var.security_group_id
}

module udp_rule {
	source = "../ingress-generic"
	ports = [1514]
	cidr = [module.constants.aex_siem_server_cidr]
	protocol = "udp"
	description = "SIEM agent"
	security_group_id = var.security_group_id
}
