variable zone_id {
	type = string
	description = "The zone id"
}

variable a_records {
	type = map(string)
	description = "list of A records"
}

variable a_records_ttl {
	type = map(tuple([string, number]))
	description = "list of A records with TTL"
	default = {}
}

variable c_names {
	type = map(string)
	description = "list of C_NAME records"
}

variable c_names_ttl {
	type = map(tuple([string, number]))
	description = "list of C_NAME records with TTL"
	default = {}
}

variable mx {
	type = map(string)
	description = "list of MX records"
	default = {}
}

variable srv {
	type = map(string)
	description = "list of SRV records"
	default = {}
}

variable ns {
	type = map(list(string))
	description = "list of NS records"
	default = {}
}

variable txt {
	type = map(list(string))
	description = "list of TXT records"
	default = {}
}

variable ttl {
	type = number
	default = 3600
}

variable ns_ttl {
	type = number
	default = 3600
}

data aws_route53_zone zone {
	zone_id = var.zone_id
}

output zone_id {
	value = data.aws_route53_zone.zone.zone_id
	depends_on = [data.aws_route53_zone.zone]
}
