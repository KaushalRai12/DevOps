resource aws_db_option_group mssql_default {
	count = var.deploy_databases ? 1 : 0
	name = "aex-mssql-default"
	option_group_description = "Scripted options for all platform MSSQL DB instances"
	engine_name = local.sql_server_engine
	major_engine_version = "${local.sql_major_engine_version}.00"

	option {
		option_name = "SQLSERVER_BACKUP_RESTORE"

		option_settings {
			name = "IAM_ROLE_ARN"
			value = data.aws_iam_role.manual_backups.arn
		}
	}

	option {
		option_name = "SQLSERVER_AUDIT"

		option_settings {
		 	name  = "S3_BUCKET_ARN"
		 	value = "${var.logs_bucket_arn}/sql-server-audit-logs"
	    }
		
		option_settings {
			name = "IAM_ROLE_ARN"
			value = aws_iam_role.rds_audit_logs_role.arn
		}

		option_settings {
			name = "ENABLE_COMPRESSION"
			value = true
		}
    }
}

resource aws_db_parameter_group mssql_default {
	count = var.deploy_databases ? 1 : 0
	name = "aex-mssql-default"
	family = "sqlserver-se-15.0"

	parameter {
		name = "database mail xps"
		value = 1
	}
}

resource aws_db_instance database_mssql {
	count = var.deploy_databases ? 1 : 0
	identifier = local.rds_name
	engine = one(aws_db_option_group.mssql_default).engine_name
	engine_version = "${local.sql_major_engine_version}.00.4073.23.v1"
	instance_class = var.db_instance_type
	allocated_storage = var.allocated_storage
	max_allocated_storage = var.max_allocated_storage
	storage_type = var.db_storage_type
	storage_encrypted = true
	multi_az = false
	publicly_accessible = false
	username = "admin"
	password = var.portal_sql_password
	port = 1433
	timezone = var.rds_time_zone
	character_set_name = "Latin1_General_CI_AS"
	license_model = "license-included"
	deletion_protection = true
	db_subnet_group_name = var.db_subnet_group_name
	vpc_security_group_ids = [var.db_security_group_id]
	enabled_cloudwatch_logs_exports = ["error", "agent"]
	maintenance_window = "Sun:00:00-Sun:01:00"
	auto_minor_version_upgrade = var.auto_minor_version_upgrade
	performance_insights_enabled = true
	performance_insights_retention_period = 7
	monitoring_role_arn = data.aws_iam_role.monitoring.arn
	monitoring_interval = 60
	copy_tags_to_snapshot = true
	apply_immediately = true
	skip_final_snapshot = true
	option_group_name = one(aws_db_option_group.mssql_default).name
	parameter_group_name = one(aws_db_parameter_group.mssql_default).name
	timeouts {
		create = "2h"
		delete = "2h"
		update = "2h"
	}

	tags = merge({
		Name = var.cluster_fqn
		"aex/backup/rds" : var.cluster_env
	}, var.extra_rds_tags)

	lifecycle {
		ignore_changes = [engine_version]
	}
}

resource aws_security_group_rule data_access {
	count = var.expose_to_vpn ? 1 : 0
	security_group_id = var.db_security_group_id
	type = "ingress"
	description = "VPN SQL Server Access"
	from_port = 1433
	to_port = 1433
	protocol = "tcp"
	cidr_blocks = concat(tolist(module.constants.db_access_cidrs), [module.constants.operations_cidr])
}

module friendly_domain {
	count = var.deploy_databases ? 1 : 0
	source = "../dns-cname/modules/unwrapped"
	domain_name = local.domain_name
	target = aws_db_instance.database_mssql[0].address
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}

resource aws_iam_role rds_audit_logs_role {
	name = "rds-audit-logs-role"
	assume_role_policy = data.aws_iam_policy_document.rds_audit_logs_role.json
}

resource aws_iam_policy rds_audit_logs_policy {
	name = "rds-audit-logs-policy"
	description = "Policy to allow RDS to write audit logs to S3"
	policy = data.aws_iam_policy_document.rds_audit_logs_policy_document.json

}

data aws_iam_policy_document rds_audit_logs_role {
	statement {
		effect = "Allow"
		principals {
			type = "Service"
			identifiers = ["rds.amazonaws.com"]
		}
		actions = ["sts:AssumeRole"]
	}
}

data aws_iam_policy_document rds_audit_logs_policy_document {
	statement {
		sid = "S3Access"
		effect = "Allow"
		actions = ["s3:PutObject"]
        resources = ["${var.logs_bucket_arn}/*"]
	}

}

resource aws_s3_object  sql_server_audit_log{
  bucket = var.log_bucket_name
  key    = "sql-server-audit-logs/"
}

resource aws_iam_role_policy rds_audit_logs_policy {
	name = "rds-audit-logs-policy"
	policy = data.aws_iam_policy_document.rds_audit_logs_policy_document.json
	role = aws_iam_role.rds_audit_logs_role.id
}
