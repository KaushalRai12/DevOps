module rule {
	source = "../ingress-generic"
	ports = ["443"]
	cidr = ["0.0.0.0/0"]
	description = var.description
	security_group_id = var.security_group_id
}
