locals {
	kibana_domain = "logs.${module.constants_cluster.cluster_name}.${module.constants.aex_i11l_systems_domain}"
	elastic_domain = "elastic-logs.${module.constants_cluster.cluster_name}.${module.constants.aex_i11l_systems_domain}"
	kube_context = module.constants_env.k8s_context
	cluster_name =  module.constants_cluster.cluster_name
	cluster_env = module.constants_env.cluster_env
	eks_cluster_name = "${replace(local.cluster_name, "-", "_")}_${local.cluster_env}"
	aws_profile = module.constants_cluster.aws_profile
	elastic_version = "7.17.1"
}

module constants_cluster {
	source = "../../../../modules/constants"
}

module constants_env {
	source = "../../modules/constants"
}

module constants {
	source = "../../../../../../modules/aws/constants"
}
