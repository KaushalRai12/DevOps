resource aws_security_group_rule rule {
	type = "ingress"
	security_group_id = var.security_group_id
	from_port = 8
	to_port = 0
	protocol = "icmp"
	description = coalesce(var.description, "Ping from anywhere")
	cidr_blocks = length(var.cidr) == 0 ? ["0.0.0.0/0"] : var.cidr
}
