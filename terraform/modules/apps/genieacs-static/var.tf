module constants {
	source = "../../aws/constants"
}

locals {
  cwmp_port = 80
  nbi_port = 7557
  fs_port = 7567
  gui_port = 3000
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
	default = "t3.small"
}

variable key_prefix {
	type = string
	default = ""
}

data aws_route53_zone lookup {
	name = module.constants.aex_i11l_systems_domain
  provider = aws.dns
}

data aws_lb lookup {
	arn = var.load_balancer_arn
}

data aws_lb_listener http {
  load_balancer_arn = var.load_balancer_arn
  port = 80
}

data aws_lb_listener https {
  load_balancer_arn = var.load_balancer_arn
  port = 443
}

data aws_vpc vpc {
	id = var.vpc_id
}
