resource "helm_release" "kubernetes_dashboard" {
	name = "kubernetes-dashboard"
	repository = "https://kubernetes.github.io/dashboard/"
	chart = "kubernetes-dashboard"
	version = "4.0.2"
	namespace = "kubernetes-dashboard"
	create_namespace = true
	values = [
		file("${path.module}/values.yaml")
	]
}

resource "helm_release" "kubernetes_dashboard_extras" {
	name = "kubernetes-dashboard-extras"
	chart = "${path.module}/helm"
	namespace = "kubernetes-dashboard"
	create_namespace = true
}

