locals {
	aws_profile = module.constants_cluster.aws_profile
	cluster_name = module.constants_cluster.cluster_name
	cluster_short_name = module.constants_cluster.cluster_shortname
	vpc_cidr = module.constants_env.vpc_cidr
	integration_cidr = module.constants_env.integration_cidr
	cluster_environment = module.constants_env.cluster_env
	cluster_fqn = "${local.cluster_name}_${local.cluster_environment}"
	mssql_central_password = jsondecode(data.aws_secretsmanager_secret_version.db_secrets.secret_string)["mssql-central-password"]
	elastic_data_password = jsondecode(data.aws_secretsmanager_secret_version.db_secrets.secret_string)["elastic-data-password"]
}

module constants {
	source = "../../../../../modules/aws/constants"
}

module constants_env {
  source = "../modules/constants"
}

module constants_cluster {
  source = "../../../modules/constants"
}

data aws_region current {}

module ami {
	source = "../../../../../modules/aws/ami"
}

module deploy_constants {
	source = "../../../modules/constants"
}

data aws_dx_gateway transit {
	name = "vumatel-1"
	provider = aws.transit
}

data aws_secretsmanager_secret_version db_secrets {
	secret_id = "db-credentials"
}

data aws_acm_certificate default {
	domain = "*.${module.constants.aex_i11l_systems_domain}"
}

data aws_caller_identity account {}
