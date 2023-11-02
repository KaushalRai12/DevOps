locals {
	image_tag = "0.1.21"
	image_name = "gitlab.vumaex.net:4567/internal/devops/devops-server"
	docker_hash = sha1(join("", [for f in fileset("${path.module}/docker", "**") : filesha1("${path.module}/docker/${f}")]))
	private_key = base64encode("${chomp(data.aws_secretsmanager_secret_version.private_key.secret_string)}\n")
	ansible_password_windows = jsondecode(data.aws_secretsmanager_secret_version.service.secret_string)["ansible-password-windows"]
}

data aws_secretsmanager_secret_version private_key {
	secret_id = "devops-service-private-key"
	provider = aws.secrets
}

data aws_secretsmanager_secret_version service {
	secret_id = "devops-service"
	provider = aws.secrets
}
