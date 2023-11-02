terraform {
  backend "s3" {
    bucket         = "vumatel-tf-state"
    dynamodb_table = "tf-state-lock"
    encrypt        = true
    key            = "preprod/env/dev/apps/metricsserver"
    profile        = "vumatel-operations"
    region         = "af-south-1"
  }
}
