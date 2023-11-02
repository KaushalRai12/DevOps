resource helm_release db-servers {
	name = "db-servers"
	chart = "${path.module}/helm"
	namespace = "aex-devops"

	set {
		name = "deployUnitTestServer"
		value = var.deploy_unit_test_server
	}

	set {
		name = "deployMainServer"
		value = var.deploy_main_server
	}

	set {
		name = "isCloudDeploy"
		value = var.is_cloud_deploy
	}
}
