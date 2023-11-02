variable cluster_name {
	description = "full cluster name - becomes part of the bucket name"
	type = string
}

variable cluster_env {
	description = "cluster environment"
}

locals {
	suffix = var.cluster_env == "prod" ? "" : "-${var.cluster_env}"
	bucket_name = "aex-${replace(var.cluster_name, "_", "-")}${local.suffix}-system-artifacts"
	account_id = data.aws_caller_identity.current.account_id
}

data aws_caller_identity current {}
