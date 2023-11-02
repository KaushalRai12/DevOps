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
	default_tags {
		tags = {
			managed = "terraform"
		}
	}
}

provider aws {
	alias = "dns"
	profile = "vumatel-operations"
	region = "af-south-1"
	default_tags {
		tags = {
			managed = "terraform"
		}
	}
}
