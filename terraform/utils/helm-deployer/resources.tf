resource template_dir config {
	source_dir = "./docker"
	destination_dir = "./docker-rendered"

	vars = {
		user_token_ci_robot_prod = local.user_token_ci_robot_prod
		user_token_ci_robot = local.user_token_ci_robot
		aws_secret_vumatel = local.aws_secret_vumatel
		aws_secret_vumatel_operations = local.aws_secret_vumatel_operations
		aws_secret_vumatel_preprod = local.aws_secret_vumatel_preprod
	}
}

resource null_resource build {
	triggers = {
		dir_hash = local.docker_hash
		tag = local.image_tag
	}
	provisioner local-exec {
		working_dir = "./docker-rendered"
		command = "docker build -t ${local.image_name}:${local.image_tag} ."
	}
	depends_on = [template_dir.config]
}

resource null_resource push {
	triggers = {
		dir_hash = local.docker_hash
		tag = local.image_tag
	}
	provisioner local-exec {
		command = "docker push ${local.image_name}:${local.image_tag}"
	}
	depends_on = [null_resource.build]
}
