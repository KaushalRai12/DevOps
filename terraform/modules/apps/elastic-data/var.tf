variable opensearch_values {
	type = list(string)
	default = []
}

variable dashboard_values {
	type = list(string)
	default = []
}

variable suffix {
	type = string
	default = "logs"
}

variable opensearch_version {
	type = string
	default = "1.7.4"
}

variable dashboard_version {
	type = string
	default = "1.2.0"
}

//========= locals
locals {
	namespace = "aex-devops"
	repo = "https://opensearch-project.github.io/helm-charts"
	dashboard_name = "opensearch-${var.suffix}-dashboards"
	opensearch_name = "opensearch-${var.suffix}"
}

//==========outputs
output dashboard_name {
	value = local.dashboard_name
}

output opensearch_name {
	value = local.opensearch_name
}
