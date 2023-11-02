module rule {
	source = "../ingress-generic"
	ports = var.ports
	cidr = setunion(module.constants.vumatel_access_cidrs)
	protocol = var.protocol
	description = var.description
	security_group_id = var.security_group_id
}
