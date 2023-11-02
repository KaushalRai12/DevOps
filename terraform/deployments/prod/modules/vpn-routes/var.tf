variable route_table_id {
	description = "Id of the route table to which to add the route"
	type = string
}

variable transit_gateway_id {
	description = "Id of the transit gateway"
	type = string
}

module constants_cluster {
	source = "../../modules/constants"
}
