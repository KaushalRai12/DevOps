# Can add another IP at some point. Also do external. To do, when doing so

module external_ingress {
	source = "../../../../../../modules/aws/ip-proxy-load-balancer"
	purpose = "external"
	internal = false
	cluster_fqn = module.constants_env.cluster_fqn
	vpc_id = module.constants_env.vpc_id
	subnets = data.aws_subnets.public_subnets.ids
	extra_tags = { "terraform": "apps/fixed-ip-ingress" }
}

module https_traffic_rule {
	source = "./port-forwarding"
	source_port = 443
	protocol = "TCP"
	description = "HTTPS Traffic"
	target_type = "alb"
	cidr = ["0.0.0.0/0"]
	# Don't specify the security_group_id if no rule should be created
	# security_group_id = data.aws_security_group.alb_web_public.id
	target_ids = toset([data.aws_lb.alb_web_public.arn])
	load_balancer_arn = module.external_ingress.load_balancer_arn
	health_check_port = 443
	health_check_protocol = "HTTPS"
	extra_tags = { "terraform": "apps/fixed-ip-ingress" }
}

module http_traffic_rule {
	source = "./port-forwarding"
	source_port = 80
	protocol = "TCP"
	description = "HTTP Traffic"
	target_type = "alb"
	cidr = ["0.0.0.0/0"]
	# Don't specify the security_group_id if no rule should be created
	# security_group_id = data.aws_security_group.alb_web_public.id
	target_ids = toset([data.aws_lb.alb_web_public.arn])
	load_balancer_arn = module.external_ingress.load_balancer_arn
	health_check_port = 80
	health_check_protocol = "HTTP"
	extra_tags = { "terraform": "apps/fixed-ip-ingress" }
}

module integrations_ingress {
	source = "../../../../../../modules/aws/ip-proxy-load-balancer"
	purpose = "integrations"
	internal = true
	cluster_fqn = module.constants_env.cluster_fqn
	vpc_id = module.constants_env.vpc_id
	subnets = data.aws_subnets.nms_subnets.ids
	extra_tags = { "terraform": "apps/fixed-ip-ingress" }
}

# module huawei_snmp_trap_rule {
# 	source = "./port-forwarding"
# 	source_port = 1620
# 	cidr = module.constants_cluster.nms_routes
# 	protocol = "UDP"
# 	description = "RT Systems SNMP Traps"
# 	security_group_id = data.aws_security_group.nms_services_private.id
# 	target_ids = toset(data.aws_instances.nms_workers.ids)
# 	load_balancer_arn = module.integrations_ingress.load_balancer_arn
# 	health_check_port = 80
# 	extra_tags = { "terraform": "apps/fixed-ip-ingress" }
# }

module huawei_snmp_trap_rule {
	source = "./port-forwarding"
	source_port = 1621
	cidr = module.constants_cluster.nms_routes
	protocol = "UDP"
	description = "Huawei SNMP Traps"
	security_group_id = data.aws_security_group.nms_services_private.id
	target_ids = toset(data.aws_instances.nms_workers.ids)
	load_balancer_arn = module.integrations_ingress.load_balancer_arn
	health_check_port = 80
	extra_tags = { "terraform": "apps/fixed-ip-ingress" }
}

module zhone_snmp_trap_rule {
	source = "./port-forwarding"
	source_port = 162 # Can't customize ports on Zhone :facepalm:
	destination_port = 1622
	cidr = module.constants_cluster.nms_routes
	protocol = "UDP"
	description = "Zhone SNMP Traps"
	security_group_id = data.aws_security_group.nms_services_private.id
	target_ids = toset(data.aws_instances.nms_workers.ids)
	load_balancer_arn = module.integrations_ingress.load_balancer_arn
	health_check_port = 80
	extra_tags = { "terraform": "apps/fixed-ip-ingress" }
}

module calix_snmp_trap_rule {
	source = "./port-forwarding"
	source_port = 1623
	cidr = module.constants_cluster.nms_routes
	protocol = "UDP"
	description = "Calix SNMP Traps"
	security_group_id = data.aws_security_group.nms_services_private.id
	target_ids = toset(data.aws_instances.nms_workers.ids)
	load_balancer_arn = module.integrations_ingress.load_balancer_arn
	health_check_port = 80
	extra_tags = { "terraform": "apps/fixed-ip-ingress" }
}

# module active_e_snmp_trap_rule {
# 	source = "./port-forwarding"
# 	source_port = 1624
# 	cidr = module.constants_cluster.nms_routes
# 	protocol = "UDP"
# 	description = "ActiveE SNMP Traps"
# 	security_group_id = data.aws_security_group.nms_services_private.id
# 	target_ids = toset(data.aws_instances.nms_workers.ids)
# 	load_balancer_arn = module.integrations_ingress.load_balancer_arn
# 	health_check_port = 80
# 	extra_tags = { "terraform": "apps/fixed-ip-ingress" }
# }

module external_database_rule {
	source = "./port-forwarding"
	source_port = 36363
	destination_port = 1433
	cidr = module.constants.vumatel_data_access_cidrs
	protocol = "TCP"
	description = "MSSQL Access"
	security_group_id = data.aws_security_group.prod_db_private.id
	target_type = "ip"
	target_ids = toset(data.dns_a_record_set.prod_db.addrs)
	load_balancer_arn = module.external_ingress.load_balancer_arn
	health_check_port = 1433
	extra_tags = { "terraform": "apps/fixed-ip-ingress" }
}
