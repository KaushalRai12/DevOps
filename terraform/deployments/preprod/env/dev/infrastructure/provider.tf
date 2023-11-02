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
		onepassword = {
			source = "1Password/onepassword"
			version = "~> 1.1.2"
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

provider aws {
	alias = "operations"
	profile = "vumatel-operations"
	region = "af-south-1"
	default_tags {
		tags = {
			managed = "terraform"
		}
	}
}

provider aws {
	alias = "transit"
	profile = "vumatel-transit"
	region = "af-south-1"
	default_tags {
		tags = {
			managed = "terraform"
		}
	}
}

provider helm {
	kubernetes {
		config_context = "aex-development-dev"
	}
}

