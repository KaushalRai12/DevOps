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

provider aws {
	region = module.constants_cluster.aws_region
	profile = module.constants_cluster.aws_profile
}

provider helm {
	kubernetes {
		config_context = module.constants_cluster.kube_context
	}
}
