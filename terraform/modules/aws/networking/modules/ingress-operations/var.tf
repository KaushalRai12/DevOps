variable security_group_id {
	description = "Security group identifier"
	type = string
}

variable operations_cidr {
	description = "Optional CIDR of operations account - defaults to the value in constants module"
	type = string
	default = null
}

variable from_port {
  description = "Start port"
	type = number
}

variable to_port {
  description = "End port - defaults to the start port"
	type = number
	default = null
}

variable protocol {
	description = "Protocol to use (e.g. TCP or UDP)"
	default = "TCP"
}

locals {
	cidr = coalesce(var.operations_cidr, module.constants.operations_cidr)
	to_port = coalesce(var.to_port, var.from_port)
}

module constants {
	source = "../../../constants"
}
