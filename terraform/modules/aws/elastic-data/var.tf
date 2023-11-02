variable dashboard_domain {
	type = string
}

variable opensearch_domain {
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

variable opensearch_values {
	description = "Custom values for the opensearch helm chart"
	type = string
	default = null
}

variable dashboard_values {
	description = "Custom values for the dashboards helm chart"
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
	default = "data"
}

variable opensearch_version {
	type = string
	default = "1.7.4"
}

variable dashboard_version {
	type = string
	default = "1.2.0"
}

variable root_domain {
	description = "Root domain (zone)"
	type = string
	default = "vumaex.net"
}

variable k8s_namespace {
	description = "K8s namespace in which to put this cluster."
	type =  string
	default = "aex-devops"
}

variable has_ingress {
	description = "Set to false to disable ALL ingress capabilities"
	type = bool
	default = true
}

locals {
	prefix = var.cluster_env == "prod" ? "" : "${var.cluster_env}-"
	opensearch_name = "${local.prefix}opensearch-${var.suffix}"
}
