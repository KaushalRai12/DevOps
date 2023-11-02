variable vpc_id {
	type = string
}

variable security_group_id {
	type = string
}

variable subnet_ids {
	type = set(string)
}

variable cluster_env {
	type = string
}

variable cluster_name {
	type = string
}

