variable service_name {
	description = "name of the service deployed fno, work-orders, nms"
	type = string
}

variable cluster_name {
	description = "cluster short name"
	type = string
}

variable domain_environment {
	description = "domain environment: prod, dev etc"
	type = string
}

variable external_root_domain {
	type = string
	default = "vumaex.net"
}

variable internal_root_domain {
	type = string
	default = "vumaex.net"
}

variable vpc_id {
	type = string
}

variable target_port {
	type = number
	default = 80
}

variable targets {
	description = "List of target instances"
	type = set(string)
}

variable external_lb_dns {
	description = "Full domain name of external load balancer"
	type = string
}

variable internal_lb_dns {
	description = "Full domain name of internal load balancer"
	type = string
}

variable external_lb_arn_suffix {
	type = string
	description = "The ARN suffix of the external load balancer"
}

variable internal_lb_arn_suffix {
	type = string
	description = "The ARN suffix of the internal load balancer"
}

variable port_443_arn {
	description = "ARN of the port 443 external listener"
	type = string
}

variable port_443_internal_arn {
	description = "ARN of the port 443 internal listener"
	type = string
}

variable port_80_internal_arn {
	description = "ARN of the port 80 internal listener"
	type = string
}

variable error_actions {
	description = "Array of actions, typically the ARNs of SNS topics, to trigger when an Error alarm changes state"
	type = set(string)
	default = null
}

variable warning_actions {
	description = "Array of actions, typically the ARNs of SNS topics, to trigger when a Warning alarm changes state"
	type = set(string)
	default = null
}

variable extra_internal_domains {
	description = "Extra internal domains to be added to the route"
	type = set(string)
	default = []
}

variable extra_external_domains {
	description = "Extra external domains to be added to the route"
	type = set(string)
	default = []
}

locals {
	domain_prefix = var.domain_environment == "prod" ? "" : "${var.domain_environment}."
	domain_template ="${local.domain_prefix}|.${var.cluster_name}"
	internal_domain = "${replace(local.domain_template, "|", var.service_name)}.${var.internal_root_domain}"
	external_domain = "${replace(local.domain_template, "|", var.service_name)}.${var.external_root_domain}"
	target_group_name = replace(replace("${local.domain_prefix}${var.service_name}|", ".", "-"), "_", "-")
}

module constants {
	source = "../../../constants"
}
