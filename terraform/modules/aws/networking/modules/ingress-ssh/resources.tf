resource aws_security_group_rule rule {
	type = "ingress"
	description = "SSH tmp, pending VPN - TO BE DELETED"
	from_port = 22
	to_port = 22
	protocol = "tcp"
	cidr_blocks = var.cidr
	security_group_id = var.security_group_id
}
