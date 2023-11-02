resource aws_iam_role autoscaler {
	assume_role_policy = templatefile("${path.module}/templates/eks-iam-service-account-role-policy.json.tpl", {
		cluster_arn = var.cluster_arn
		cluster_url = var.cluster_url
		namespace = local.namespace
		service_account_name = local.service_account_name
	})
	name = "AmazonEKSClusterAutoscalerRole_${var.cluster_fqn}"
}

resource aws_iam_role_policy_attachment autoscaler {
	policy_arn = data.aws_iam_policy.autoscaler.arn
	role = aws_iam_role.autoscaler.name
}

resource helm_release autoscaler {
	name = "cluster-autoscaler"
	repository = "https://kubernetes.github.io/autoscaler"
	chart = "cluster-autoscaler"
	version = "9.10.7"
	namespace = local.namespace
	values = [
		templatefile("${path.module}/templates/autoscaler-values.yaml", {
			cluster_name = var.cluster_name
			role_arn = aws_iam_role.autoscaler.arn
			aws_region = data.aws_region.current.name
			service_account_name = local.service_account_name
		})
	]
	depends_on = [aws_iam_role_policy_attachment.autoscaler]
}
