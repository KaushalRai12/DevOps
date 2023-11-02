variable route_table_id {
	description = "The ID of the route table"
	type = string
}

variable transit_gateway_id {
	description = "The ID of the transit gateway"
	type = string
}

variable routes {
	description = "The list of routes"
	type = set(string)
}
