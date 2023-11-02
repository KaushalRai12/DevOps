provider "aws" {
  region  = local.aws_region
  profile = local.aws_profile

  default_tags {
    tags = {
      managed-by   = "Terraform"
      supported-by = "devops@vumatel.co.za"
    }
  }
}