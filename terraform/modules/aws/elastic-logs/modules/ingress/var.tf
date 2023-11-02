variable kibana_domain {
	type = string
}

variable elastic_domain {
	type = string
}

variable cluster_env {
	type = string
}

variable eks_cluster_name {
	type = string
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

variable is_internal {
	type = bool
	default = true
	description = "Set to false to expose the ES instance to the public"
}

variable elastic_name {
	description = ""
	type = string
}

variable kibana_name {
	description = ""
	type = string
}

variable root_domain {
	type = string
	default = "vumaex.net"
}

variable k8s_namespace {
	description = "K8s namespace in which to put this cluster. Logs usually go in aex-devops, where data can on it its target namespace."
	type =  string
	default = "aex-devops"
}

variable elastic_prefix {
	description = "Elastic name prefix: elastic or opensearch"
	type = string
	default = "elastic"
}

locals {
	namespace = var.k8s_namespace
	prefix = var.cluster_env == "prod" || var.cluster_env == null ? "" : "${var.cluster_env}-"
	kibana_name = "${local.prefix}kibana-${var.suffix}"
	kibana_domain = "${trimsuffix(var.kibana_domain, ".${var.root_domain}")}.${var.root_domain}"
	elastic_domain = "${trimsuffix(var.elastic_domain, ".${var.root_domain}")}.${var.root_domain}"
}

data aws_region current {}

output elastic_domain {
	description = "Resulting elastic domain"
	value = local.elastic_domain
}
