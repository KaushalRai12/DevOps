terraform {
  backend "s3" {
    bucket         = "vumatel-tf-state"
    dynamodb_table = "tf-state-lock"
    encrypt        = true
    key            = "prod/env/prod/apps/metricsserver"
    profile        = "vumatel-operations"
    region         = "af-south-1"
  }
}
