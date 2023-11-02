module data {
	source = "../../apps/elastic-data"
	suffix = var.suffix
	opensearch_version = var.opensearch_version
	dashboard_version = var.dashboard_version
	opensearch_values = compact([
		templatefile("${path.module}/templates/opensearch-values.yaml", {
			name = local.opensearch_name
			service_type = var.has_ingress ? "LoadBalancer" : "ClusterIP"
		}),
		var.opensearch_values
	])
	dashboard_values = compact([var.dashboard_values])
}

module ingress {
	source = "../elastic-logs/modules/ingress"
	count = var.has_ingress ? 1 : 0
	aws_profile = var.aws_profile
	cluster_env = var.cluster_env
	domain_suffix = var.domain_suffix
	eks_cluster_name = var.eks_cluster_name
	elastic_domain = var.opensearch_domain
	elastic_name = module.data.opensearch_name
	kibana_domain = var.dashboard_domain
	kibana_name = module.data.dashboard_name
	root_domain = var.root_domain
	elastic_prefix = "opensearch"
	is_internal = true
	suffix = var.suffix
	k8s_namespace = var.k8s_namespace
	providers = {
		aws.dns = aws.dns
	}
}
