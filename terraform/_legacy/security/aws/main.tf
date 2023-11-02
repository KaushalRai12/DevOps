terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 3.0"
		}
	}

	backend "s3" {
		bucket = "tf-state.aex"
		key = "global/security/aws"
		region = "af-south-1"
		dynamodb_table = "tf-state-lock"
	}
}

provider "aws" {
	region = "af-south-1"
}
