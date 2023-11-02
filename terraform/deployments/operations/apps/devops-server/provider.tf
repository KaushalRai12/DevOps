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

provider aws {
	region = module.constants_cluster.aws_region
	profile = module.constants_cluster.aws_profile
	default_tags {
		tags = {
			managed = "terraform"
		}
	}
}

provider helm {
	kubernetes {
		config_context = local.k8s_context
	}
}

provider aws {
	alias = "secrets"
	profile = "vumatel-central"
	region = "af-south-1"
	default_tags {
		tags = {
			managed = "terraform"
		}
	}
}