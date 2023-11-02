variable kube_context {
	type = string
}

variable namespaces {
	type = set(string)
}

locals {
	auth_patch = templatefile("${path.module}/templates/aws-auth-patch.json.tpl", {
		terraform_user_arn: data.aws_iam_user.terraformer.arn
		helm_user_arn: data.aws_iam_user.helm_deployer.arn
		k8s_developer_user_arn: data.aws_iam_user.k8s_developer.arn
		k8s_power_user_arn: data.aws_iam_user.k8s_power_user.arn
	})
}

data aws_iam_user terraformer {
	user_name = "terraformer"
}

data aws_iam_user helm_deployer {
	user_name = "helm-deployer"
}

data aws_iam_user k8s_developer {
	user_name = "k8s-developer"
}

data aws_iam_user k8s_power_user {
	user_name = "k8s-power-user"
}
