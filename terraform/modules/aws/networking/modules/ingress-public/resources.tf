module rule {
	source = "../ingress-generic"
	ports = var.ports
	cidr = ["0.0.0.0/0"]
	protocol = var.protocol
	description = var.description
	security_group_id = var.security_group_id
}
