resource helm_release metrics_server {
	name = local.name
	repository = "https://kubernetes-sigs.github.io/metrics-server/"
	chart = local.name
	version = var.metrics_server_version
	namespace = local.namespace
	values = [
		templatefile("${path.module}/templates/metrics-server-values.yaml", {})
	]
}