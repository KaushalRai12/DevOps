variable vpc_id {
	type = string
}

variable efs_subnet_ids {
	type = set(string)
	default = null
}

variable efs_allowed_source_group_ids {
	type = set(string)
	default = null
}

variable db_security_group_id {
	type = string
}

variable db_instance_type {
	type = string
	default = "db.m5.xlarge"
}

variable db_storage_type {
	description = "Database storage type"
	type = string
	default = "gp2"
}

variable allocated_storage {
	type = number
	default = 100
}

variable max_allocated_storage {
	type = number
	default = 200
}

variable cluster_fqn {
	type = string
}

variable cluster_env {
	description = "Cluster environment, e.g. dev, prod"
	type = string
}

variable domain_env {
	description = "Optional environment override for the domain name"
	type = string
	default = null
}

variable cluster_name {
  description = "Name of the cluster"
	type = string
}

variable portal_sql_password {
	type = string
	sensitive = true
}

variable deploy_databases {
	type = bool
	default = true
}

variable deploy_efs {
	type = bool
	default = true
}

variable db_subnet_group_name {
	type = string
}

variable expose_to_vpn {
	type = bool
	default = false
}

variable extra_rds_tags {
	description = "Extra tags to add to the RDS"
	type = map(string)
	default = {}
}

variable auto_minor_version_upgrade {
	description = "Set to `true` to auto upgrade minor versions of the DBMS"
	type = bool
	default = false
}

variable rds_time_zone {
	description = "timezone of the DB server"
	type = string
	default = "South Africa Standard Time"
}

variable rds_name {
	type = string
	default = null
}

variable root_domain {
	description = "Root domain for friendly DNS records"
	type = string
	default = "vumaex.net"
}

locals {
	rds_name = var.rds_name == null ? replace(var.cluster_fqn, "_", "-") : var.rds_name
	sql_major_engine_version = "15"
	sql_server_engine = "sqlserver-se"
	domain_prefix = coalesce(var.domain_env, var.cluster_env) == "prod" ? "" : "${coalesce(var.domain_env, var.cluster_env)}."
	domain_name = "${local.domain_prefix}sql.${var.cluster_name}.${var.root_domain}"
}

module constants {
	source = "../constants"
}

data aws_iam_role monitoring {
	name = "aex-rds-enhanced-monitoring"
}

data aws_iam_role manual_backups {
	name = module.constants.manual_backups_role
}

output efs_id {
	value = var.deploy_efs ? aws_efs_file_system.efs_file_system[0].id : null
}

output sql_address {
	value = var.deploy_databases ? aws_db_instance.database_mssql[0].address : null
}

variable logs_bucket_arn {
	type = string
}

variable log_bucket_name {
	type = string
}
