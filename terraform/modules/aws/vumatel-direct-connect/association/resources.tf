resource aws_dx_gateway_association_proposal vumatel_1 {
	dx_gateway_id = var.gateway_id
	dx_gateway_owner_account_id = "483107167038" # Transit account. Not sure how to do this dynamically
	associated_gateway_id = var.vpn_gateway_id
}

resource aws_dx_gateway_association vumatel_1 {
	provider = aws.transit
	proposal_id = aws_dx_gateway_association_proposal.vumatel_1.id
	dx_gateway_id = var.gateway_id
	associated_gateway_owner_account_id = data.aws_caller_identity.current.account_id
	allowed_prefixes = [
		var.vpc_cidr,
	]
}
