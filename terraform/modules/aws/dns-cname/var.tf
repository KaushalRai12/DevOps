variable domain_name {
	type = string
}

variable target {
	type = string
}

variable root_domain {
	type = string
	default = "vumaex.net"
}

data aws_route53_zone zone {
	name = var.root_domain
	provider = aws.dns
}
