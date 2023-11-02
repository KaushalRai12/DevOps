variable k8s_runner_tag {
	type = string
}

variable cache_bucket_name {
	type = string
}

variable allow_local_gitlab {
	type = bool
	default = false
}

variable cache_key {
	type = string
}

variable cache_secret {
	type = string
}

variable cpu_request {
	type = string
	default = "200m"
}

variable memory_request {
	type = string
	default = "500Mi"
}

variable gitlab_url {
	type = string
	default = "gitlab.vumaex.net"
}

variable registration_token {
	type = string
}

variable name_suffix {
	type = string
	default = null
}

variable piggyback {
	type = bool
	default = false
}

variable requires_stable_nodes {
	description = "The runner pod should go on stable (On DEMAND) nodes only"
	type = bool
	default = true
}

//============ locals
locals {
	namespace = "aex-devops"
	# Hosts can be removed once this chart is no longer used in Rosebank - these values are ignore in AWS
	local_hosts = { "10.69.11.29" = "gitlab.automationexchange.co.za" }
	host_map = var.allow_local_gitlab ? local.local_hosts : {}

	cache_bucket_region = "af-south-1"
	name_suffix = var.name_suffix == null ? "" : "-${var.name_suffix}"
	name = "gitlab-runner-kubernetes${local.name_suffix}"
}
