variable protocol {
	type = string
	default = "tcp"
}

variable description {
	type = string
	default = null
}

variable security_group_id {
	type = string
}

variable ports {
	type = set(string)
}

module constants {
	source = "../../../constants"
}
