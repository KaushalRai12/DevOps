variable domain_name {
	type = string
}

variable root_domain {
	type = string
	default = "vumaex.net"
}

variable name {
	type = string
	default = null
}

variable cluster_environment {
	type = string
	default = null
}

module constants {
	source = "../constants"
}

locals {
	we_control_domain = contains(module.constants.route53_domains, var.root_domain)
	count_cap = local.we_control_domain ? 1 : 0
}

data aws_route53_zone zone {
	count = local.count_cap
	name = var.root_domain
	provider = aws.dns
}

output certificate_arn {
	value = length(aws_acm_certificate_validation.validation) > 0 ? aws_acm_certificate_validation.validation[0].certificate_arn : aws_acm_certificate.certificate.arn
}
