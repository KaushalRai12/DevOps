terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.0"
		}
		helm = {
			source = "hashicorp/helm"
			version = "~> 2.0"
		}
	}
}

provider helm {
	kubernetes {
		config_context = module.constants_cluster.kube_context
	}
}

provider aws {
	region = "af-south-1"
	profile = "vumatel-operations"
}

