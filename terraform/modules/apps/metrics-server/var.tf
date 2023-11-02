variable metrics_server_version {
	type = string
}

locals {
	namespace = "kube-system"
	name = "metrics-server"
}

