resource helm_release mock_server {
	name = local.name
    chart = "${path.module}/helm"
	namespace = var.namespace
	values = compact([
		templatefile("${path.module}/helm/values/values.yaml", {
			nameOverride: local.name,
			image_tag: var.image_tag,
			environment: var.environment,
			repository: local.repository
		})
	])
}