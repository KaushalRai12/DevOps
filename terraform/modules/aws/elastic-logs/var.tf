variable kibana_domain {
	type = string
}

variable elastic_domain {
	type = string
}

variable kube_context {
	type = string
}

variable cluster_env {
	type = string
}

variable eks_cluster_name {
	type = string
}

variable elastic_values {
	description = "Customise helm chart values for Elasticsearch"
	type = string
	default = null
}

variable kibana_values {
	description = "Customise helm chart values for Kibana"
	type = string
	default = null
}

variable domain_suffix {
	type = string
}

variable aws_profile {
	type = string
}

variable suffix {
	type = string
	default = "logs"
}

variable elastic_version {
	type = string
	default = "7.9.3"
}

variable kibana_version {
	type = string
	default = "7.9.3"
}

variable root_domain {
	description = "The root domain for DNS records"
	type = string
	default = "vumaex.net"
}

variable is_internal {
	type = bool
	default = true
	description = "Set to false to expose the ES instance to the public"
}

variable purpose {
	description = "Set to 'logs' or 'data'"
	type = string
	default = "logs"
}

variable has_ingress {
	description = "Set to false to disable ALL ingress capabilities"
	type = bool
	default = true
}

locals {
	namespace = "aex-devops"
	prefix = var.cluster_env == "prod" || var.cluster_env == null ? "" : "${var.cluster_env}-"
	elastic_name = "${local.prefix}elastic-${var.suffix}"
	kibana_name = "${local.prefix}kibana-${var.suffix}"
	is_logs = var.purpose == "logs"
}

data aws_region current {}
