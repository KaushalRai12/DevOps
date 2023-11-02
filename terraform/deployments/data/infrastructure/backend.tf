terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.20"
    }
  }
  backend "s3" {
    bucket         = "vumatel-tf-state"
    dynamodb_table = "tf-state-lock"
    encrypt        = true
    key            = "data/infrastructure"
    profile        = "vumatel-operations"
    region         = "af-south-1"
  }
}
