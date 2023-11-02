variable listener_arn {
	type = string
	description = "ARN of the LB listener - this does not create it's own listener"
}

variable internal_listener_arn {
	type = string
	description = "ARN of the internal LB listener - this does not create it's own listener"
	default = null
}

variable domain_environment {
	type = string
	description = "Environment name for the domain e.g. stage, prod"
}

variable cluster_name {
	type = string
	default = null
	description = "Cluster name e.g. gcpud, national-us, us, dev"
}

variable portal_name {
	type = string
	description = "Name of the portal route"
}

variable external_root_domain {
	type = string
	description = "Root domain for the given domain. If using route53, this must be the same as the zone name"
	default = "automationexchange.tech"
}

variable internal_root_domain {
	description = "Root domain for friendly DNS records"
	type = string
	default = "vumaex.net"
}

variable extra_domains {
	description = "Extra domains to be bound to the Portal endpoint"
	type = set(string)
	default = []
}

variable vpc_id {
	type = string
}

variable portal_server_ids {
	type = set(string)
	description = "Instance Ids of the portal server"
}

variable health_check_protocol {
	description = "Protocol used for health checks"
	type = string
	default = "HTTPS"
}

variable target_port {
	type = number
	default = 443
}

variable lb_dns {
	type = string
	description = "DNS of the load balancer"
}

variable internal_lb_dns {
	type = string
	description = "DNS of the internal load balancer"
	default = null
}

variable lb_arn_suffix {
	type = string
	description = "The ARN suffix of the load balancer"
}

variable can_add_dns {
	type = bool
	description = "Set this to false if you want to force the system to NOT add DNS, event if we control the domain name. System will auto-detect domain ownership."
	default = true
}

variable target_group_name {
	type = string
	default = null
}

variable certificate_arn {
	description = "Optionally send your own certificate ARN"
	type = string
	default = null
}

variable domain_name {
	description = "optional override for domain name"
	type = string
	default = null
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

locals {
	domain_prefix = var.domain_environment == "prod" ? "" : "${var.domain_environment}."
	domain_suffix = var.cluster_name != null && var.portal_name != null ? join(".", distinct([var.portal_name, var.cluster_name])) : coalesce(var.cluster_name, var.portal_name)
	portal_domain = coalesce(var.domain_name, "${local.domain_prefix}${local.domain_suffix}.${var.external_root_domain}")
	internal_portal_domain = "${local.domain_prefix}${local.domain_suffix}.${var.internal_root_domain}"
	target_group_name = join("-", compact([var.domain_environment, "portal"]))
	internal_target_group_name = "${local.target_group_name}-internal"
}

module constants {
	source = "../../../constants"
}

