variable cluster_name {
	description = "Name of the VPC cluster, e.g national-us"
	type = string
}

variable kube_context {
	description = "Name kubernetes context"
	type = string
}

variable cluster_env {
	description = "Name cluster env, e.g. dev, prod"
	type = string
}

variable domain_prefix {
	description = "Name domain env, e.g. dev, prod"
	type = string
	default = null
}

variable suffix {
	description = "requestd instance suffix"
	type = string
	default = null
}

variable storage_capacity {
	description = "Storage capacity assigned to volume claim"
	type = string
}

variable root_domain {
	description = "Root domain for friendly DNS records"
	type = string
	default = "vumaex.net"
}

variable gitlab_domain {
	description = "Gitlab DNS name"
	type = string
	default = "gitlab.vumaex.net"
}

locals {
	prefix = var.domain_prefix == null ? "" : "${var.domain_prefix}."
	suffix = var.suffix == null ? "" : "-${var.suffix}"
	elastic_version = "7.17.3"
	kibana_domain = "${local.prefix}kibana-requestd${local.suffix}.${var.cluster_name}"
	elastic_domain = "${local.prefix}elastic-requestd${local.suffix}.${var.cluster_name}"
	requestd_version = "1.1.0"
}

data aws_iam_account_alias current {}

module constants {
	source = "../../aws/constants"
}
