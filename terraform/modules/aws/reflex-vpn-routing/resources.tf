# This says reflex. Busy replacing it with the Vumatel VPN stuff
module routes {
	source = "./modules/routes"
	for_each = toset(data.aws_route_tables.routable.ids)
	route_table_id = each.value
	transit_gateway_id = var.transit_gateway_id
	vpc_id = var.vpc_id
	extra_vpn_routes = var.extra_vpn_routes
}

resource aws_security_group_rule ping {
	for_each = toset(data.aws_security_groups.pingable.ids)
	security_group_id = each.value
	type = "ingress"
	description = "VPN Ping"
	from_port = 8
	to_port = 0
	protocol = "icmp"
	cidr_blocks = setunion(module.constants.vumatel_access_cidrs)
}

resource aws_security_group_rule ssh {
	for_each = toset(data.aws_security_groups.ssh.ids)
	security_group_id = each.value
	type = "ingress"
	description = "VPN SSH"
	from_port = 22
	to_port = 22
	protocol = "tcp"
	cidr_blocks = setunion(module.constants.vumatel_access_cidrs)
}

resource aws_security_group_rule prtg {
	for_each = toset(data.aws_security_groups.ssh.ids)
	security_group_id = each.value
	type = "ingress"
	description = "PRTG Monitoring"
	from_port = 161
	to_port = 161
	protocol = "udp"
	cidr_blocks = module.constants.vumatel_prtg_cidrs
}

resource aws_security_group_rule rdp {
	for_each = toset(data.aws_security_groups.rdp.ids)
	security_group_id = each.value
	type = "ingress"
	description = "VPN RDP"
	from_port = 3389
	to_port = 3389
	protocol = "tcp"
	cidr_blocks = setunion(module.constants.vumatel_access_cidrs)
}
