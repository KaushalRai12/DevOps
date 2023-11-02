terraform {
	required_providers {
		helm = {
			source = "hashicorp/helm"
			version = "~> 3.0"
		}
	}

	backend "s3" {
		bucket = "tf-state.aex"
		key = "global/networking/api-gateway"
		region = "af-south-1"
		dynamodb_table = "tf-state-lock"
	}
}

provider "helm" {
	kubernetes {
		config_context = "aex-dev"
	}
}

provider "helm" {
	alias = "prod"
	kubernetes {
		config_context = "aex-prod"
	}
}
