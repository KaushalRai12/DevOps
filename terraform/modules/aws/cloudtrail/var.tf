variable cluster_name {
	description = "The name of the cluster"
	type = string
}

variable org_prefix {
	description = "Organisational prefix for your bucket"
	type = string
	default = "aex"
}

variable is_organization_trail {
	description = "Whether or not this is an organization trail - i.e. master trail for the entire org"
  type = bool
	default = false
}

data aws_caller_identity current {}
