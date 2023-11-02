variable vpc_id {
	description = "VPC ID"
	type = string
}

variable cluster_name {
	description = "Cluster name - used as a suffix, e.g. jump.{cluster_name}.aex.blue"
	type = string
}

variable ami_id {
	description = "Optional AMI ID, leave off to auto select an AMI"
	type = string
	default = null
}

variable internal_root_domain {
	description = "Internal server domain"
	type = string
	default = "vumaex.blue"
}

variable public_root_domain {
	description = "Public facing root domain"
	type = string
	default = "vumaex.net"
}

module constants {
	source = "../../aws/constants"
}

module ami {
	source = "../../aws/ami"
}

data aws_subnets this {
	filter {
		name = "vpc-id"
		values = [var.vpc_id]
	}
	tags = {
		"aex/public": "true"
		"aex/az": "a"
	}
}

data aws_security_groups this {
	filter {
		name   = "vpc-id"
		values = [var.vpc_id]
	}
	tags = {
		"aex/service": "true"
	}
}

data aws_route53_zone public_zone {
	name = var.public_root_domain
	provider = aws.dns
}
