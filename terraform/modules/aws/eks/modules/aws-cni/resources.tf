resource kubectl_manifest this {
	for_each = { for i, s in split("---", file("${path.module}/templates/manifest.yaml")) : i => s }
	yaml_body = each.value
}

/*
NOTE: managed add-on does not seem to work - hence manual manifest application (above)
see: https://github.com/aws/amazon-vpc-cni-k8s/issues/1322
resource "aws_eks_addon" "eks_cni" {
	cluster_name = var.cluster_fqn
	addon_name = "vpc-cni"
	addon_version = "v1.9.0-eksbuild.1"
	resolve_conflicts = "OVERWRITE"
	service_account_role_arn = var.role_arn
}
*/
