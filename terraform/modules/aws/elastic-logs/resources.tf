module logs {
	source = "../../apps/elastic-logs"
	suffix = var.suffix
	elastic_version = var.elastic_version
	kibana_version = var.kibana_version
	elastic_values = compact([
		templatefile("${path.module}/templates/elastic-values.yaml", {
			name = local.elastic_name
			service_type = var.has_ingress ? "LoadBalancer" : "ClusterIP"
		}),
		var.elastic_values
	])
	kibana_values = compact([var.kibana_values])
}

module ingress {
	source = "./modules/ingress"
	count = var.has_ingress ? 1 : 0
	aws_profile = var.aws_profile
	cluster_env = var.cluster_env
	domain_suffix = var.domain_suffix
	eks_cluster_name = var.eks_cluster_name
	elastic_domain = var.elastic_domain
	elastic_name = module.logs.elastic_name
	kibana_domain = var.kibana_domain
	kibana_name = module.logs.kibana_name
	is_internal = var.is_internal
	suffix = var.suffix
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}
