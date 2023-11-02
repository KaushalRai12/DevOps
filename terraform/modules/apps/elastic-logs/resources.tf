resource helm_release elasticsearch {
	name = local.elastic_name
	repository = local.repo
	chart = "elasticsearch"
	version = var.elastic_version
	namespace = local.namespace
	values = compact(concat(
		[templatefile("${path.module}/templates/elastic-values.yaml", { suffix : var.suffix })],
		var.elastic_values
	))
}

resource helm_release kibana {
	name = local.kibana_name
	repository = local.repo
	chart = "kibana"
	version = var.kibana_version
	namespace = local.namespace
	values = compact(concat(
		[templatefile("${path.module}/templates/kibana-values.yaml", { suffix : var.suffix })],
		var.kibana_values
	))
}
