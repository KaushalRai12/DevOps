# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
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
		config_context = module.constants_env.k8s_context
	}
}

provider aws {
	region = module.constants_cluster.aws_region
	profile = module.constants_cluster.aws_profile
}

provider aws {
	alias = "vumatel_operations"
	profile = "vumatel-operations"
	region = "af-south-1"
}
