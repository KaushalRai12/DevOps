terraform {
	required_providers {
		helm = {
			source = "hashicorp/helm"
			version = "~> 2.0"
		}

		# k8s = {
		# 	source = "hashicorp/kubernetes"
		# 	version = "~> 2.0"
		# }

		kubectl = {
			source = "gavinbunney/kubectl"
			version = ">= 1.7.0"
		}

		aws = {
			source = "hashicorp/aws"
			version = "~> 4.0"
			configuration_aliases = [aws.secrets]
		}
	}
}

provider helm {
	kubernetes {
		config_context = var.kube_context
	}
}

provider kubectl {
	config_context = var.kube_context
}

// NOTE: this will cause issues in a new cluster, because there is no such kube context from the start
// used to create namespaces. todo: separate so that the context is created before this is needed
// workaround: comment this out for the first run
# provider k8s {
# 	config_context = var.kube_context
# }
