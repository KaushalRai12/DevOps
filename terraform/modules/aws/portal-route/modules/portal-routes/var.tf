variable listener_arn {
	type = string
	description = "ARN of the LB listener - this does not create it's own listener"
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

variable external_root_domain {
	description = "Route public root domain"
	type = string
}

variable internal_root_domain {
	description = "Route private root domain"
	type = string
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

variable lb_arn_suffix {
	type = string
	description = "The ARN suffix of the load balancer"
}

variable can_add_dns {
	type = bool
	description = "Set this to false if you want to force the system to NOT add DNS, event if we control the domain name. System will auto-detect domain ownership."
	default = true
}

variable portal_names {
	type = set(string)
	description = "Names of the portal routes"
}

variable routes {
	description = "Use this in addition to portal_names, where you want to specify different details per route"
	type = list(object({
		name : string
		root_domain : string
		target_group_name : string
	}))
	default = []
}

locals {
	routes = {
	for route in concat(var.routes, [
	for name in var.portal_names : {
		name : name
		root_domain : var.external_root_domain
		target_group_name : "${var.domain_environment}-${replace(name, ".", "-")}"
	}
	]) : route.target_group_name => route
	}
	target_group_name = join("-", compact([var.domain_environment, "portal"]))
}
