# constants_cluster
locals {
	cluster_name = "vumatel" # Should technically be prod, but needs to be vumatel for the transition
	aws_profile = "vumatel-prod" # hardcoding these to ease the transition
	aws_region = "af-south-1"
	logs_bucket = "vumatel-prod-logs" # hardcoding these to ease the transition
	rosebank_nms_routes = []
	# TODO Move these to a more global setup
	vumatel_nms_routes = [
		"10.88.10.0/24", # Vumatel CMS
		"10.88.12.0/24", # Vumatel NCE
		"10.42.0.0/16", # Reflex NCE, ZMS and Switches
		"160.119.142.216/29", # Cape Town BNGs
	]
	vumatel_domain = "vumatel.co.za"
}

output cluster_name {
	value = local.cluster_name
}

output cluster_shortname {
	value = "vumatel"  # Should technically be prod, but needs to be vumatel for the transition
}

output aws_profile {
	value = local.aws_profile
}

output aws_region {
	value = local.aws_region
}

output aws_preferred_az {
	value = "${local.aws_region}a"
}

output logs_bucket {
	value = local.logs_bucket
}

output rosebank_nms_routes {
	description = "Extra ranges to route to rosebank"
	value = local.rosebank_nms_routes
}

output vumatel_nms_routes {
	description = "Extra ranges to route to Vumatel"
	value = local.rosebank_nms_routes
}

output nms_routes {
	description = "All routes that go to NMS elements"
	value = toset(concat(local.rosebank_nms_routes, local.vumatel_nms_routes))
}

output vpn_routes {
	description = "All routes that go through the Reflex VPN elements"
	value = toset(concat(local.rosebank_nms_routes))
}

output vumatel_domain {
	description = "Primary Vumatel domain name"
	value = local.vumatel_domain
}
