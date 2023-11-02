resource helm_release opensearch {
	name = local.opensearch_name
	repository = local.repo
	chart = "opensearch"
	version = var.opensearch_version
	namespace = local.namespace
	values = concat(
	[templatefile("${path.module}/templates/opensearch-values.yaml", {
		full_name : local.opensearch_name
	})],
	var.opensearch_values
	)
}

resource helm_release dashboards {
	name = local.dashboard_name
	repository = local.repo
	chart = "opensearch-dashboards"
	version = var.dashboard_version
	namespace = local.namespace
	values = concat(
	[templatefile("${path.module}/templates/dashboard-values.yaml", {
		full_name: local.dashboard_name
		opensearch_name: local.opensearch_name
	})],
	var.dashboard_values
	)
}
