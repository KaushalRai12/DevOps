terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 4.0"
			configuration_aliases = [aws.cognito, aws.dns]
		}
	}
}

provider aws {
	alias = "cognito"
	profile = var.aws_profile
	region = local.cognito_region
}
