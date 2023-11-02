variable listener_arn {
	type = string
}

variable lb_dns {
	type = string
	description = "DNS of the load balancer"
}

variable lb_arn_suffix {
	type = string
	description = "The ARN suffix of the load balancer"
}

variable domain {
	type = string
}

variable encrypted {
	type = bool
	default = true
}

variable vpc_id {
	type = string
}

variable target_port {
	type = number
	default = 80
}

variable targets {
	description = "Target instance ids, no need to set this if you already have a target group"
	type = set(string)
	default = []
}

variable target_type {
	type = string
	default = "instance"
}

variable target_protocol {
	type = string
	default = "HTTP"
}

variable target_group_name {
	description = "Name of target group to create - only applicable if there is no target group ARN"
	type = string
	default = null
}

variable target_group_arn {
	description = "send this if you already have a target group"
	type = string
	default = null
}

variable can_add_dns {
	type = bool
	default = true
}

variable root_domain {
	description = "Set this as a default root domain, in-case you don't want to send a root domain with every ARN"
	type = string
	default = "vumaex.net"
}

variable create_target_group {
	type = bool
	default = true
}

variable certificate_arn {
	description = "Optionally send your own certificate ARN"
	type = string
	default = null
}

variable health_check_protocol {
	description = "Protocol used for health checks"
	type = string
	default = "HTTP"
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

variable response_time_threshold {
	description = "The upper threshold of the response time, in seconds, of the target"
	type = string
	default = 0.5
}

variable extra_domains {
	description = "Extra domains to be added to the route"
	type = set(string)
	default = []
}

variable is_internal {
	description = "Is this on an internal domain"
	type = bool
	default = false
}

module constants {
	source = "../../../constants"
}

locals {
	domain = replace(var.domain, "_", "-")
	we_control_domain = contains(module.constants.route53_domains, var.root_domain)
}

data aws_route53_zone root {
	count = local.we_control_domain ? 1 : 0
  name = var.root_domain
	provider = aws.dns
	private_zone = var.is_internal
}

output target_group_arn {
	value = var.create_target_group ? one(aws_lb_target_group.target).arn : null
}
