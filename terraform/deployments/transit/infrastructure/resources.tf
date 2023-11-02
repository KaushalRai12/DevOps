module terraformer {
	source = "../../../modules/aws/general/modules/terraformers"
}

module reflex_gateway {
	source = "../../../modules/aws/customer-gateway"
	customer_gateway_ip = "154.72.6.178"
	customer_gateway_target = "reflex"
}

module afrihost_gateway {
	source = "../../../modules/aws/customer-gateway"
	customer_gateway_ip = "169.1.1.84"
	customer_gateway_target = "afrihost"
}

module logs {
	source = "../../../modules/aws/log-bucket"
	log_bucket_name = local.logs_bucket
}

module vpc {
	source = "../../../modules/aws/vpc"
	cluster_fqn = local.cluster_fqn
	vpc_cidr = local.vpc_cidr
	logs_bucket_arn = module.logs.bucket_arn
}

module constants {
	source = "../../../modules/aws/constants"
}

module reflex_vpn {
	source = "../../../modules/aws/vpn"
	name = "transit-to-reflex"
	customer_gateway_id = module.reflex_gateway.customer_gateway_id
	gateway_id = aws_ec2_transit_gateway.central.id
	is_transit = true
	encryption_algorithms = ["AES256"]
	hash_algorithms = ["SHA2-256"]
	force_static_routes = true
	transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit.id
}

module afrihost_vpn {
	source = "../../../modules/aws/vpn"
	name = "transit-to-afrihost"
	customer_gateway_id = module.afrihost_gateway.customer_gateway_id
	gateway_id = aws_ec2_transit_gateway.central.id
	is_transit = true # Check this
	encryption_algorithms = ["AES128", "AES256"]
	hash_algorithms = ["SHA2-256"]
	ike_versions = ["ikev1", "ikev2"]
	phase1_dh_group_numbers = ["2", "14"]
	force_static_routes = true
	transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.transit.id
}

module aws_cloudtrail {
 source = "../../../modules/aws/cloudtrail"
 cluster_name = local.cluster_name
 org_prefix = "vumatel"
}