terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.0"
		}
	}
}

provider aws {
	region = "af-south-1"
	profile = "vumatel-transit"
}
