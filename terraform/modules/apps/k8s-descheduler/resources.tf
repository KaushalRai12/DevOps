resource helm_release descheduler {
	name = "kubernetes-descheduler"
	repository = "https://kubernetes-sigs.github.io/descheduler"
	chart = "descheduler"
	version = "0.23.2"
	namespace = "kube-system"
	values = concat([
		file("${path.module}/templates/values.yaml")
	], var.values)
}
