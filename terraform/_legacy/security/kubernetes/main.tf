terraform {
	required_providers {
		helm = {
			source = "hashicorp/helm"
			version = "~> 2.0"
		}
	}

	backend "s3" {
		bucket = "tf-state.aex"
		key = "global/security/kubernetes"
		region = "af-south-1"
		dynamodb_table = "tf-state-lock"
	}
}

provider "helm" {
	kubernetes {
		config_context = "aex-prod"
	}
}
