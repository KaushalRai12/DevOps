provider "aws" {
  region  = module.constants_cluster.aws_region
  profile = module.constants_cluster.aws_profile
}

provider "aws" {
  alias   = "identity"
  region  = module.constants_cluster.alternate_aws_region
  profile = module.constants_cluster.aws_profile
}