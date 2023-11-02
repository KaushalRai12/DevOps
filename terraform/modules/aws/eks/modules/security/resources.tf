resource null_resource patch_auth {

	triggers = {
		input = filesha256("${path.module}/templates/aws-auth-patch.json.tpl")
	}

	provisioner local-exec {
		command = "kubectl --context ${var.kube_context} -n kube-system patch cm aws-auth --patch '${local.auth_patch}'"
	}
}

resource helm_release global_roles {
	name = "global-roles"
	chart = "${path.module}/helm"
	namespace = "aex-devops"
	set {
		name = "namespaces"
		value = "{${join(",", var.namespaces)}}"
	}
}
