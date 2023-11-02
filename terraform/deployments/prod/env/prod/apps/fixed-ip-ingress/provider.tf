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
	default_tags {
		tags = {
			managed = "terraform"
		}
	}
}
