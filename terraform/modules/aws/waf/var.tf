variable cluster_fqn {
	description = "Cluster fully qualified name"
	type = string
}

variable vpc_id {
	description = "VPC ID"
	type = string
}

variable log_group_retention_in_days {
	description = "Number of days to retain the logs"
	type = number
	default = 30
}

variable rate_limit {
	description = "The number of requests to the same URL allowed within a 5 minute period. Leave zero (default) to disable rate limiting."
	type = number
	default = 0
}

variable rate_limit_override_ip_ranges {
	description = "Specify the CIDR ranges should be allowed to override rate limits. This is only applicable if there is a rate limit."
	type = list(string)
	default = []
}

variable allowed_countries {
	description = "Set allowed countries. Setting this to empty will allow all countries. These must be two-character country codes, for example, [ \"ZA\", \"US\" ], from the alpha-2 country ISO codes of the ISO 3166 international standard."
	type = list(string)
	default = []
}

variable geo_whitelisted_ip_ranges {
	description = "Specify the CIDR ranges that should to be whitelisted. This is only applicable if there is a country restriction"
	type = list(string)
	default = []
}

variable blocked_countries {
	description = "Set blocked countries. These must be two-character country codes, for example, [ \"ZA\", \"US\" ], from the alpha-2 country ISO codes of the ISO 3166 international standard."
	type = list(string)
	default = []
}

variable geo_blacklisted_ip_ranges {
	description = "Specify the CIDR ranges that should to be blacklisted."
	type = list(string)
	default = []
}

locals {
	cluster_fqn = replace(var.cluster_fqn, "_", "-")
	has_country_restriction = signum(length(var.allowed_countries))
	geo_blocked_response = "cr-geo-blocked"
	rate_limit_response = "cr-rate-limited"
	geo_whitelisted_ip_ranges = concat(var.geo_whitelisted_ip_ranges, module.constants.static_ips, tolist(module.constants.vumatel_access_cidrs))
	geo_blacklisted_ip_ranges = concat(var.geo_blacklisted_ip_ranges, [
		"118.193.41.23/32",
	])
}

data aws_resourcegroupstaggingapi_resources load_balancers {
	resource_type_filters = ["elasticloadbalancing:loadbalancer"]

	tag_filter {
		key = "aex/waf/protected"
		values = [var.vpc_id]
	}
}

module constants {
	source = "../constants"
}
