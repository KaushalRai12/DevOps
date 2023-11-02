module constants {
	source = "../../aws/constants"
}

locals {
	authentication_port = 1812
	accounting_port = 1813
	external_ip_addresses = ["10.184.0.210/32", "10.184.0.68/32"] # Can probably look them up
	afrihost_cidr = ["172.29.11.152/29", "172.29.11.160/29"]
	access_cidr_blocks = setunion(
		local.external_ip_addresses,
		local.afrihost_cidr,
		module.constants.vumatel_bng_cidrs,
		module.constants.vumatel_prtg_cidrs,
	)
}

variable load_balancer_arn {
	type = string
	description = "The ARN of the load balancer to attach to"
}

variable cluster_fqn {
	type = string
	description = "used to construct the domain name, along with domain_purpose"
}

variable cluster_env {
	type = string
}

variable cluster_name {
	type = string
}

variable domain_environment {
	type = string
	description = "Environment name for the app e.g. stage, prod"
}

variable vpc_id {
	type = string
	description = "The ID of the VPC in which the FreeRADIUS app will live"
}

variable subnets {
	type = set(string)
	description = "The IDs of the Subnets in which the FreeRADIUS app will live"
}

variable ami_id {
	type = string
	description = "The AMI to create the EC2 instances from"
}

variable instance_type {
	type = string
	description = "The instance type for EC2 instances"
	default = "t3.medium"
}

variable key_prefix {
	type = string
	default = ""
}

data aws_instances accounting {
	instance_tags = {
		"aex/purpose" = "freeradius-accounting"
	}
	filter {
		name = "vpc-id"
		values = [var.vpc_id]
	}
}

data aws_instances authentication {
	instance_tags = {
		"aex/purpose" = "freeradius-authentication"
	}
	filter {
		name = "vpc-id"
		values = [var.vpc_id]
	}
}
