variable protocol {
	type = string
	default = "tcp"
}

variable description {
	type = string
}

variable cidr {
	type = set(string)
}

variable security_group_id {
	type = string
}

variable ports {
	type = set(string)
}
