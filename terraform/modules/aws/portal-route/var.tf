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

variable domain_name {
	description = "optional override for domain name"
	type = string
	default = null
}

variable extra_domains {
	description = "Extra domains to be bound to the Portal endpoint"
	type = set(string)
	default = []
}

variable external_root_domain {
	type = string
	description = "Root domain for the given domain. If using route53, this must be the same as the zone name"
	default = "automationexchange.tech"
}

variable internal_root_domain {
	type = string
	description = "Root domain for the given domain. If using route53, this must be the same as the zone name"
	default = "vumaex.net"
}

variable vpc_id {
	type = string
}

variable portal_server_ids {
	type = set(string)
	description = "Instance Ids of the portal server"
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

