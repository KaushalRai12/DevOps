resource aws_security_group_rule data_access {
	security_group_id = data.aws_security_group.eks.id
	type = "ingress"
	description = "VPN PostgreSQL Access"
	from_port = 5432
	to_port = 5432
	protocol = "tcp"
	cidr_blocks = concat(tolist(module.constants.db_access_cidrs), [module.constants.operations_cidr])
}
