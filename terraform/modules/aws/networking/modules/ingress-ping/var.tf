variable security_group_id {
 type = string
}

variable cidr {
	type = set(string)
	default = []
}

variable description {
	type = string
	default = null
}
