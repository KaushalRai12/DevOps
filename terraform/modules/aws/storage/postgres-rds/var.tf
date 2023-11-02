variable db_identifier {
	type = string
}

variable cluster_env {
	description = "Cluster environment, e.g. dev, prod"
	type = string
}

variable cluster_name {
	description = "Name of the cluster"
	type = string
}

variable parameter_group_name {
	type = string
	default = null
}

variable instance_class {
	type = string
}

variable engine_version {
	type = string
}

variable publicly_accessible {
	type = bool
	default = false
}

variable allocated_storage {
	type = number
	default = 10
}

variable max_allocated_storage {
	type = number
	default = 200
}

variable password {
	type = string
}

variable db_security_group_id {
	type = string
}

variable deletion_protection {
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

variable enable_performance_insights {
	type = bool
	default = true
}

variable root_domain {
	description = "Root domain for friendly DNS records"
	type = string
	default = "vumaex.net"
}

locals {
	domain_prefix = var.cluster_env == "prod" ? "" : "${var.cluster_env}."
	domain_name = "${local.domain_prefix}${var.db_identifier}-pg.${var.cluster_name}.${var.root_domain}"
}

// ============ Data
data aws_iam_role monitoring {
	name = "aex-rds-enhanced-monitoring"
}
