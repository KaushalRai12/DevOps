resource helm_release prometheus {
	name = "prometheus"
	repository = "https://prometheus-community.github.io/helm-charts"
	chart = "kube-prometheus-stack"
	// Can be upgraded to v34, but i think we need to wipe the old helm release - TBI
	// https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
	version = "33.2.1"
	namespace = "aex-devops"
	values = concat([
		templatefile("${path.module}/templates/values.yaml", {
			namespaces : var.namespaces
			aws_region : data.aws_region.current.name
			// I suspect we need to bounce the devops nodes to get the new role permissions to take effect. sts:AssumeRole is added but no effect.
			//aws_role_arn: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aex-prometheus"
			aws_access_key : var.aws_access_key
			aws_secret_key : var.aws_secret_key
			smtp_username : local.smtp_username
			smtp_password : local.smtp_password
			slack_url: local.slack_url,
			vpc_id: var.vpc_id
		})
	], var.values)
}

/*
resource helm_release prometheus_push_gateway {
	name = "prometheus-push-gateway"
	repository = "https://prometheus-community.github.io/helm-charts"
	chart = "prometheus-pushgateway"
	version = "1.16.1"
	namespace = "aex-devops"
	values = [
		file("${path.module}/templates/values-pushgateway.yaml")
	]
}
*/
