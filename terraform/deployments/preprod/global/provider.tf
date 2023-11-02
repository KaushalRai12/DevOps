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

provider aws {
	alias = "operations"
	profile = "vumatel-operations"
	region = "af-south-1"
}

provider aws {
	alias = "transit"
	profile = "vumatel-transit"
	region = "af-south-1"
}
