terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.0"
		}
	}
}

provider aws {
	profile = "vumatel-operations"
	region = "af-south-1"
}
