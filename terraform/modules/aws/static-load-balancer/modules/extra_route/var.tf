variable domain {
	type = string
	description = "The FQDN of the extra route"
}

variable root_domain {
	type = string
	description = "The root domain of the extra route"
}

variable cluster_fqn {
	type = string
	description = "The FQDN of the cluster"
}

variable load_balancer_name {
	type = string
	default = null
}

variable load_balancer_dns_name {
	type = string
	description = "The name of the LB listener to which the DNS needs to point. Only used if you have an IP LB before your App LB."
	default = null
}

variable target_override {
	type = string
	description = "Use this to override the target DNS"
	default = null
}

data aws_lb static {
	name = var.load_balancer_name == null ? "${replace(var.cluster_fqn, "_", "-")}-svc" : var.load_balancer_name
}

data aws_lb dns {
	name = var.load_balancer_dns_name == null ? (var.load_balancer_name == null ? "${replace(var.cluster_fqn, "_", "-")}-svc" : var.load_balancer_name) : var.load_balancer_dns_name
}

data aws_lb_listener static_443 {
	load_balancer_arn = data.aws_lb.static.arn
	port = 443
}

data aws_route53_zone zone {
	provider = aws.dns
	name = var.root_domain
}

