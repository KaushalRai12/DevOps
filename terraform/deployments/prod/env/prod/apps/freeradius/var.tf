locals {
	cluster_name = module.constants_cluster.cluster_name
	cluster_shortname = module.constants_cluster.cluster_shortname
	cluster_environment = "prod"
	cluster_fqn = "${local.cluster_name}_${local.cluster_environment}"
	domain_environment = "prod"
	ami_id = "ami-09f0252cc9f724947"
	radius_sql_password = jsondecode(data.aws_secretsmanager_secret_version.db_secrets.secret_string)["radius-db-password"]
}

module constants_env {
	source = "../../modules/constants"
}

module constants_cluster {
	source = "../../../../modules/constants"
}

data aws_subnets nms_subnets {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
	tags = {
		"aex/nms" = "true"
	}
}

data aws_security_group db_private_security_group {
	name = "vumatel_prod_db_private_security_group"
}

data aws_lb internal {
	name = "vumatel-prod-ip-integrations"
}

data aws_secretsmanager_secret_version db_secrets {
	secret_id = "db-credentials"
}

data aws_iam_role monitoring {
	name = "aex-rds-enhanced-monitoring"
}
