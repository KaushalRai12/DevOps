variable service_name {
	type = string
}

variable namespace {
	type = string
}

variable subnets {
	type = list(string)
}

variable domain {
	type = string
}

variable root_domain {
	type = string
	default = "vumaex.net"
}
