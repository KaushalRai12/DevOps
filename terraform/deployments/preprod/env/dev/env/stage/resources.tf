module main {
	source = "../_common"
	env = "stage"
	api_server_ami = "ami-0ee2d5d8062f8ad99"
	windows_portal_ami = "ami-07b44382cd3ff3b28"
	nms_server_ami = "ami-074d80ce00bc0cbce"
	efs_id = "fs-05f207844ba326fec"
	logs_bucket = module.constants_env.logs_bucket
	portal_names = local.portal_names
	client_interfaces = local.client_interfaces
	installers = local.installers

	shared_services = local.shared_services
	internal_services = local.internal_services
	external_services	 = local.external_services
}
