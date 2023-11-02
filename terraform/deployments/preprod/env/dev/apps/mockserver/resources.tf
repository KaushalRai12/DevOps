module mock_server_stage {
	source = "../../../../../../modules/apps/mockserver"
	namespace = "aex-stage"
	image_tag = local.image_tag
	environment = "stage"
}

module mock_server_preprod {
	source = "../../../../../../modules/apps/mockserver"
	namespace = "aex-preprod"
	image_tag = local.image_tag
	environment = "preprod"
}

module mock_server_uat {
	source = "../../../../../../modules/apps/mockserver"
	namespace = "aex-uat"
	image_tag = local.image_tag
	environment = "uat"
}