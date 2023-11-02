resource aws_security_group_rule rule {
	for_each = var.ports
	type = "ingress"
	from_port = split("-", each.value)[0]
	to_port = split("-", each.value)[length(split("-", each.value)) - 1]
	protocol = var.protocol
	description = var.description
	cidr_blocks = var.cidr
	security_group_id = var.security_group_id
}
