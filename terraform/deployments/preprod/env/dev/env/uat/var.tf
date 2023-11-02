module constants {
	source = "../../../../../../modules/aws/constants"
}

module constants_env {
	source = "../../modules/constants"
}

module constants_cluster {
	source = "../../../../modules/constants"
}

locals {
	env = "uat"
	portal_names = [
		"vumatel",
		"api.client-prepaid",
	]

	client_interfaces = []
	installers = []
	shared_services = [
		# "search-service",
		"security-service",
		"radius-${local.env}",
		"ip-pool-manager",
		"nms-gateway",
		"sales-force-service",
		"customer-payment-service",
		"vx-service",
		# "vlan-management-service",
		"ocs-service"
	]
	internal_services = [
		"mock-server"
	]
	external_services = [
		"service-status-component",
		"fno-frontend",
		"open-speed-test"
	]
}
