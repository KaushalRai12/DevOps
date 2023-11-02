variable elastic_values {
	type = list(string)
	default = []
}

variable kibana_values {
	type = list(string)
	default = []
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

//========= locals
locals {
	namespace = "aex-devops"
	repo = "https://helm.elastic.co"
	kibana_name = "kibana-${var.suffix}"
	elastic_name = "elastic-${var.suffix}"
}

//==========outputs
output kibana_name {
	value = local.kibana_name
}

output elastic_name {
	value = local.elastic_name
}
