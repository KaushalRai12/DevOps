locals {
	image_tag = "4.2.5"
	image_name = "gitlab.vumaex.net:4567/internal/devops/helm-deployer"
	docker_hash = sha1(join("", [for f in fileset("${path.cwd}/docker", "**"): filesha1("${path.cwd}/docker/${f}")]))
	k8s_config_path = "./docker/config/k8s/config.yaml"
	aws_config_path = "./docker/config/aws/config"
	user_token_ci_robot = jsondecode(data.aws_secretsmanager_secret_version.helm_deployer.secret_string)["user-token-ci-robot"]
	user_token_ci_robot_prod = jsondecode(data.aws_secretsmanager_secret_version.helm_deployer.secret_string)["user-token-ci-robot-prod"]
	aws_secret_vumatel = jsondecode(data.aws_secretsmanager_secret_version.helm_deployer.secret_string)["aws-secret-vumatel"]
	aws_secret_vumatel_operations = jsondecode(data.aws_secretsmanager_secret_version.helm_deployer.secret_string)["aws-secret-vumatel-operations"]
	aws_secret_vumatel_preprod = jsondecode(data.aws_secretsmanager_secret_version.helm_deployer.secret_string)["aws-secret-vumatel-preprod"]
}

data aws_secretsmanager_secret_version helm_deployer {
	secret_id = "helm-deployer"
}
