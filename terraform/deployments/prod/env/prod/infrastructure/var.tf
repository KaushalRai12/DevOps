locals {
	aws_profile = module.constants_cluster.aws_profile
	cluster_name = module.constants_cluster.cluster_name
	cluster_shortname = module.constants_cluster.cluster_shortname
	vpc_prefix = "10.184.0"
	vpc_cidr = "${local.vpc_prefix}.0/18"
	integration_cidr = "${local.vpc_prefix}.0/24"
	cluster_environment = "prod"
	cluster_fqn = "${local.cluster_name}_${local.cluster_environment}"
	elastic_data_password = jsondecode(data.aws_secretsmanager_secret_version.db_secrets.secret_string)["elastic-data-password"]
	portal_sql_password = jsondecode(data.aws_secretsmanager_secret_version.db_secrets.secret_string)["portal-db-password"]
	domain_environment = "prod"
	node_instance_type = "t3.medium.elasticsearch"
	integration_subnets = concat(module.networking.eks_integration_node_subnet_ids, module.networking.nms_subnet_ids)
	error_actions = [module.constants_env.sns_error_arn]
	warning_actions = [module.constants_env.sns_warning_arn]
	external_services = [
		"radius-ct",
		"radius-kzn",
		"radius-jhb",
		"fno-frontend",
		"open-speed-test",
		"service-status-component",
		"acs"
	]
	internal_services = [
	]
	shared_services = [
		"ip-pool-manager", # Consider making this internal
		"security-service",
		"nms-gateway",
		"sales-force-service",
		"vx-service"
	]
}

data aws_secretsmanager_secret_version db_secrets {
	secret_id = "db-credentials"
}

data aws_region current {}

data aws_acm_certificate default {
	domain = "*.vumaex.net"
}

data aws_route53_zone internal {
	name = "vumaex.internal"
	provider = aws.dns
	private_zone = true
}

data aws_dx_gateway transit {
	name = "vumatel-1"
	provider = aws.transit
}

module constants {
	source = "../../../../../modules/aws/constants"
}

module constants_cluster {
	source = "../../../modules/constants"
}

module constants_env {
	source = "../modules/constants"
}

module ami {
	source = "../../../../../modules/aws/ami"
}
