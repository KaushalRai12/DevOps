module elastic {
	source = "../../aws/elastic-logs"
	aws_profile = data.aws_iam_account_alias.current.account_alias
	elastic_domain = local.elastic_domain
	kibana_domain = local.kibana_domain
	kube_context = var.kube_context
	elastic_values = templatefile("${path.module}/templates/values-elastic.yaml", { suffix : local.suffix, storage_capacity: var.storage_capacity })
	kibana_values = templatefile("${path.module}/templates/values-kibana.yaml", { suffix : local.suffix })
	elastic_version = local.elastic_version
	kibana_version = local.elastic_version
	domain_suffix = var.cluster_name
	cluster_env = null
	suffix = "requestd${local.suffix}"
	eks_cluster_name = "${var.cluster_name}_${var.cluster_env}"
	root_domain = var.root_domain
	has_ingress = false
	providers = {
		aws.dns = aws.dns
	}
}

resource helm_release requestd {
	name = "requestd${local.suffix}"
	chart = "${path.module}/helm"
	namespace = "aex-devops"
	values = [
		templatefile("${path.module}/templates/values-requestd.yaml", {
			suffix : local.suffix
			elastic_url : "${local.elastic_domain}.${module.constants.aex_i11l_systems_domain}"
			image_tag: local.requestd_version
			gitlab_domain: var.gitlab_domain
		}),
	]
}

resource helm_release memcached {
	name = "memcached${local.suffix}"
	repository = "https://charts.bitnami.com/bitnami"
	chart = "memcached"
	version = "6.1.4"
	namespace = "aex-devops"
	values = [
		templatefile("${path.module}/templates/values-memcached.yaml", { suffix : local.suffix }),
	]
}
