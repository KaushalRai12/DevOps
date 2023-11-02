locals {
	kibana_domain = "logs.dev.${module.constants.aex_i11l_systems_domain}"
	elastic_domain = "elastic-logs.dev"
	kibana_domain_rbk = "rbk-logs.dev"
	elastic_domain_rbk = "rbk-elastic-logs.dev"
	elastic_version = "7.17.1"
}

module constants {
	source = "../../../../../../modules/aws/constants"
}

module constants_env {
	source = "../../modules/constants"
}

module constants_cluster {
	source = "../../../../modules/constants"
}
