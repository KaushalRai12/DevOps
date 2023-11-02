locals {
	k8s_namespace = "devops"

	external_services = ["requestd"]
	external_service_map = [
	]

	internal_services = ["kibana-requestd"]
	internal_service_map = [
		{
			service_name : "elastic-requestd"
			domain : "elastic-requestd.${module.constants_cluster.cluster_name}"
			root_domain : module.constants.aex_i11l_systems_domain
			source_port : 9200
			target_port : 9200
			is_secure : false
		},
		{
			service_name : "kibana-logs"
			domain : "logs.${module.constants_cluster.cluster_name}"
			root_domain : module.constants.aex_i11l_systems_domain
			target_port : 5601
		},
		{
			service_name : "elastic-logs"
			domain : "elastic-logs.${module.constants_cluster.cluster_name}"
			root_domain : module.constants.aex_i11l_systems_domain
			source_port : 9200
			target_port : 9200
			is_secure : false
		},
	]
}

module constants {
	source = "../../../../../../modules/aws/constants"
}

module constants_cluster {
	source = "../../../../modules/constants"
}

module constants_env {
	source = "../../modules/constants"
}
