resource aws_security_group_rule rule {
	type = "ingress"
	description = "From operations"
	from_port = var.from_port
	to_port = local.to_port
	protocol = var.protocol
	cidr_blocks = [local.cidr]
	security_group_id = var.security_group_id
}
