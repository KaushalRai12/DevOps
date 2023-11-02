locals {
	cluster_fqn = "transit"
	vpc_cidr = "10.9.0.0/24"
	logs_bucket = "vumatel-transit-logs"
	cluster_name = "transit"
}

data aws_region current {}
