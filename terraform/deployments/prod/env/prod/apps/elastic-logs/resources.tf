module logs {
	source = "../../../../../../modules/aws/elastic-logs"
	cluster_env = local.cluster_env
	eks_cluster_name = local.eks_cluster_name
	elastic_domain = local.elastic_domain
	kibana_domain = local.kibana_domain
	kube_context = local.kube_context
	elastic_values = file("${path.module}/templates/elastic-values.yaml")
	domain_suffix = local.cluster_name
	aws_profile = local.aws_profile
	has_ingress = false
	elastic_version = local.elastic_version
	kibana_version = local.elastic_version
	providers = {
		aws.dns = aws.vumatel_operations
	}
}
