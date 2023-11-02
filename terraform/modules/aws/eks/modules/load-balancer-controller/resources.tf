resource aws_iam_role role {
	name = "AmazonEKSLoadBalancerControllerRole-${replace(var.cluster_fqn, "_", "-")}"

	assume_role_policy = templatefile("${path.module}/templates/assume-role-policy.json.tpl", {
		openid_arn = var.openid_arn, openid_url = trimprefix(var.openid_url, "https://")
	})
}

resource aws_iam_role_policy_attachment role_policy_attachment {
	role = aws_iam_role.role.name
	policy_arn = data.aws_iam_policy.lb_controller.arn
}

resource kubectl_manifest crds {
	for_each = { for i, s in split("---", file("${path.module}/templates/controller-crds.yaml")) : i => s }
	yaml_body = each.value
}

resource kubectl_manifest service_account {
	yaml_body = templatefile("${path.module}/templates/service-account-manifest.yaml", { role_arn = aws_iam_role.role.arn })
}

resource helm_release the_controller {
	name = "aws-load-balancer-controller"
	repository = "https://aws.github.io/eks-charts"
	chart = "aws-load-balancer-controller"
	version = "1.4.2"
	namespace = "kube-system"
	values = [
		file("${path.module}/templates/helm-chart-values.yaml")
	]
	set {
		name = "clusterName"
		value = var.cluster_fqn
	}
	depends_on = [kubectl_manifest.crds, kubectl_manifest.service_account]
}

