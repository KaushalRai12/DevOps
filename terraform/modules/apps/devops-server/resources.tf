resource template_dir config {
	source_dir = "${path.module}/docker"
	destination_dir = "${path.module}/docker-rendered"

	vars = {
		ansible_password_windows = local.ansible_password_windows
	}
}

resource null_resource build {
	triggers = {
		dir_hash = local.docker_hash
		tag = local.image_tag
	}
	provisioner local-exec {
		working_dir = "${path.module}/docker-rendered"
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

resource helm_release devops_server {
	name = "devops-server"
	chart = "${path.module}/helm"
	namespace = "aex-devops"

	set {
		name = "image.tag"
		value = local.image_tag
	}

	set {
		name = "image.name"
		value = local.image_name
	}

	set_sensitive {
		name = "privateKey"
		value = local.private_key
	}
	depends_on = [null_resource.push]
}

