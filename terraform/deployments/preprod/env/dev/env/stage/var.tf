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
	env = "stage"
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
		"vlan-management-service",
		"customer-payment-service",
		"vx-service",
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
