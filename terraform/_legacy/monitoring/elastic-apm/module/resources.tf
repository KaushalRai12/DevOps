locals {
	elastic_version = "7.9.3"
	namespace = "aex-devops"
	repo = "https://helm.elastic.co"
}

resource "helm_release" "elasticsearch" {
	name = "elastic-metrics"
	repository = local.repo
	chart = "elasticsearch"
	version = local.elastic_version
	namespace = local.namespace
	values = [
		file("${path.module}/elastic-values.yaml")
	]
}

resource "helm_release" "kibana" {
	name = "kibana-metrics"
	repository = local.repo
	chart = "kibana"
	version = local.elastic_version
	namespace = local.namespace
	values = [
		file("${path.module}/kibana-values.yaml")
	]
}

resource "helm_release" "apm" {
	name = "elastic-apm-server"
	repository = local.repo
	chart = "apm-server"
	version = local.elastic_version
	namespace = local.namespace
	values = [
		file("${path.module}/apm-values.yaml")
	]
}

