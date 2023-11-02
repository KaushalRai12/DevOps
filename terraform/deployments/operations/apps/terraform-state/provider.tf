terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.0"
		}
	}
}

provider aws {
	region = module.constants_cluster.aws_region
	profile = module.constants_cluster.aws_profile
}

provider aws {
	alias = "eu"
	region = "eu-west-1"
	profile = module.constants_cluster.aws_profile
}

