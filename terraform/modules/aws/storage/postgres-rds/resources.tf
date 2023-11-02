resource aws_db_instance db {
	identifier = var.db_identifier
	engine = "postgres"
	engine_version = var.engine_version
	instance_class = var.instance_class
	allocated_storage = var.allocated_storage
	max_allocated_storage = var.max_allocated_storage
	storage_type = "gp2"
	storage_encrypted = true
	multi_az = false
	publicly_accessible = var.publicly_accessible
	username = "postgres"
	password = var.password
	port = 5432
	deletion_protection = var.deletion_protection
	db_subnet_group_name = var.db_subnet_group_name
	vpc_security_group_ids = [var.db_security_group_id]
	enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
	maintenance_window = "Sun:00:00-Sun:01:00"
	auto_minor_version_upgrade = false
	performance_insights_enabled = var.enable_performance_insights
	performance_insights_retention_period = var.enable_performance_insights ? 7 : null
	monitoring_role_arn = data.aws_iam_role.monitoring.arn
	parameter_group_name = var.parameter_group_name
	monitoring_interval = 60
	copy_tags_to_snapshot = true
	apply_immediately = true
	skip_final_snapshot = true

	timeouts {
		create = "2h"
		delete = "2h"
		update = "2h"
	}

	tags = {
		Name = var.db_identifier
		"aex/backup/rds": var.cluster_env
	}

	lifecycle {
		ignore_changes = [engine_version]
	}
}

module constants {
	source = "../../constants"
}

resource aws_security_group_rule data_access {
	count = var.expose_to_vpn ? 1 : 0
	security_group_id = var.db_security_group_id
	type = "ingress"
	description = "VPN PostgreSQL Access"
	from_port = 5432
	to_port = 5432
	protocol = "tcp"
	cidr_blocks = concat(tolist(module.constants.db_access_cidrs), [module.constants.operations_cidr])
}

module friendly_domain {
	source = "../../dns-cname"
	domain_name = local.domain_name
	target = aws_db_instance.db.address
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}
