locals {
  aws_region  = "af-south-1"
  aws_profile = "vumatel-data"
}

module "constants" {
  source = "../../../modules/aws/constants"
}