#============ Kubernetes runner (Helm)
resource helm_release gitlab-runner-kubernetes {
	name = local.name
	repository = "https://charts.gitlab.io"
	chart = "gitlab-runner"
	version = "0.34.0"
	namespace = local.namespace
	values = [
		templatefile("${path.module}/templates/values-kubernetes.yaml", {
			s3_bucket = var.cache_bucket_name
			s3_region = local.cache_bucket_region
			runner_tag = var.k8s_runner_tag
			hosts = local.host_map
			cache_key = var.cache_key
			cache_secret = var.cache_secret
			cpu_request = var.cpu_request
			memory_request = var.memory_request
			gitlab_url = var.gitlab_url
			full_name = local.name
			registration_token = var.registration_token
			requires_stable_nodes = var.requires_stable_nodes
		})
	]
}

resource helm_release gitlab_runner_extras {
	count = var.piggyback ? 0 : 1
	name = "gitlab-runner-extras"
	chart = "${path.module}/helm"
	namespace = local.namespace
}

resource kubernetes_secret gitlab-s3 {
	count = var.piggyback ? 0 : 1
	type = "Opaque"
	metadata {
		name = "gitlab-s3"
		namespace = local.namespace
	}

	data = {
		accessKey = var.cache_key
		secretKey = var.cache_secret
	}
}

/*
# Experimental fargate runner: https://docs.gitlab.com/runner/configuration/runner_autoscale_aws_fargate/
# also see the gitlab helm chart: https://artifacthub.io/packages/helm/gitlab/gitlab-runner
# requires fargate cluster setup, custom docker file etc
# See: https://registry.terraform.io/modules/PackagePortal/fargate-cluster/aws/latest
resource "helm_release" "gitlab-runner-fargate" {
	name = "gitlab-runner-kubernetes-fargate"
	repository = "https://charts.gitlab.io"
	chart = "gitlab-runner"
	version = "0.26.0"
	namespace = "aex-devops"
	values = [
		data.template_file.fargate_values.rendered,,
	]
}
*/

#============ CI Metrics Exporter
/*
resource "helm_release" "gitlab-ci-exporter" {
	name = "gitlab-ci-exporter"
	repository = "https://charts.visonneau.fr"
	chart = "gitlab-ci-pipelines-exporter"
	version = "0.1.5"
	namespace = "aex-devops"
	values = [
		file("${path.module}/values-gitlab-ci-exporter.yaml"),
	]
}
*/
