# Generated by Terragrunt. Sig: nIlQXj57tbuaRZEa
terraform {
  backend "s3" {
    bucket         = "vumatel-tf-state"
    dynamodb_table = "tf-state-lock"
    encrypt        = true
    key            = "operations/apps/devops-server"
    profile        = "vumatel-operations"
    region         = "af-south-1"
  }
}
