resource "helm_release" "descheduler" {
	name = "kubernetes-descheduler"
	repository = "https://kubernetes-sigs.github.io/descheduler"
	chart = "descheduler-helm-chart"
	version = "0.19.1"
	namespace = "kube-system"
	values = [
		file("${path.module}/values.yaml")
	]
}
