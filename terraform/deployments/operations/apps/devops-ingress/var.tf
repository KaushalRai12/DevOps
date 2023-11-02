locals {
	k8s_namespace = "devops"

	external_services = []
	external_service_map = [
		{
			service_name : "nexus"
		},
		{
			name : "sonarqube"
			service_name : "sonarqube-sonarqube"
			domain : "sonarqube"
			target_port : 9000
		},
	]

	internal_services = []
	internal_service_map = [
	]
}

module constants {
	source = "../../../../modules/aws/constants"
}

module constants_cluster {
	source = "../../modules/constants"
}
