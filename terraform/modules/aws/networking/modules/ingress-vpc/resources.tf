resource aws_security_group_rule rule {
	type = "ingress"
	description = "All from VPC"
	from_port = 0
	to_port = 0
	protocol = -1
	cidr_blocks = [var.vpc_cidr]
	security_group_id = var.security_group_id
}
