resource aws_security_group_rule rule {
	type = "egress"
	description = "Egress to anywhere"
	from_port = 0
	to_port = 0
	protocol = -1
	cidr_blocks = ["0.0.0.0/0"]
	ipv6_cidr_blocks = ["::/0"]
	security_group_id = var.security_group_id
}
