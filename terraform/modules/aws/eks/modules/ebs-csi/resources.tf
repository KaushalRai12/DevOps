resource aws_iam_role service_account {
	assume_role_policy = templatefile("${path.module}/templates/eks-iam-service-account-role-policy.json.tpl", {
		cluster_arn = var.cluster_arn
		cluster_url = var.cluster_url
		namespace = local.namespace
		service_account_name = local.service_account_name
	})
	name = "AmazonEbsCsiDriveRole_${var.cluster_fqn}"
}

resource aws_iam_role_policy_attachment csi_driver {
	policy_arn = data.aws_iam_policy.ebs_csi.arn
	role = aws_iam_role.service_account.name
}

resource kubectl_manifest crds {
	for_each = { for i, s in split("---", file("${path.module}/templates/storage-class.yaml")) : i => s }
	yaml_body = each.value
}

resource helm_release this {
	name = "aws-ebs-csi-driver"
	repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
	chart = "aws-ebs-csi-driver"
	version = "2.6.2"
	namespace = local.namespace
	values = [
		templatefile("${path.module}/templates/helm-values.yaml", {
			role_arn = aws_iam_role.service_account.arn
			service_account_name = local.service_account_name
		})
	]
	depends_on = [aws_iam_role_policy_attachment.csi_driver]
}
