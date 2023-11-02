variable logs_bucket {
	description = "Name of the S3 bucket to write logs"
	type = string
}

locals {
	maintenance_tz = module.constants.region_tz[data.aws_region.current.name]
}

module constants {
	source = "../constants"
}

data aws_region current {}
