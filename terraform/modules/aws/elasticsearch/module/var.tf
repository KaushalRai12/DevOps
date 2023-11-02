variable vpc_id {
	description = "VPC ID for deployment VPC"
	type = string
}

variable ingress_cidr_blocks {
	description = "Specify CIDR blocks that can access the ES instance"
	type = set(string)
	default = []
}

variable domain {
	description = "ElasticSearch Domain"
	type = string
}

variable dedicated_master_enabled {
	description = "Select to have dedicated master node"
	type = bool
	default = true
}

variable dedicated_master_type {
	description = "master node EC2 instance type"
	type = string
	default = "m5.large.elasticsearch"
}

variable dedicated_master_count {
	description = "number of master nodes"
	type = number
	default = 3
}

variable node_instance_type {
	description = "data node EC2 instance type"
	type = string
}

variable node_instance_count {
	description = "master node EC2 instance count"
	type = number
}

variable zone_awareness_enabled {
	description = "master node EC2 instance type"
	type = bool
	default = true
}

variable availability_zone_count {
	description = "The number of AZs the domain will use"
	type = number
	default = 2
}

variable encrypt_at_rest_enabled {
	description = "Encryption of data at rest"
	type = bool
	default = true
}

variable node_to_node_encryption_enabled {
	description = "Encryption of data transferred from node to node"
	type = bool
	default = true
}

variable subnet_ids {
	description = "The ids of the subnet ids to be used by the clusters"
	type = set(string)
}

variable enforce_https {
	type = bool
  default = false
}

variable ebs_options_ebs_enabled {
	description = "Toggling EBS options"
	type = bool
	default = true
}

variable ebs_options_volume_size {
	description = "EBS volume size for the data nodes"
	type = number
	default = 50
}

variable ebs_options_volume_type {
	description = "Instance type for the data nodes"
	type = string
	default = "gp2"
}

variable password {
	description = "Supply a password if you want fine grained access control enabled. This will also enable the internal user database."
	type = string
	default = null
}

variable custom_domain {
	type = string
	default = null
}

variable root_domain {
	type = string
	default = "vumaex.net"
}

variable expose_to_vpn {
	description = "Set to true to allow 2-way access to/from AEx servers"
	type = bool
	default = false
}

variable saml_metadata {
	description = "SAML metadata content"
	type = string
	default = null
}

variable saml_master_user {
	description = "Email (automationexchange.co.za) of master user that can perform admin operations"
	type = string
	default = null
}

variable saml_entity_id {
	description = "IDP entity id"
  type = string
	default = null
}

variable saml_master_backed_role {
	description = "Master backed role for SAML"
	type = string
	default = null
}

variable slow_log_arn {
	description = "ARN for slow logs"
	type = string
}

variable app_log_arn {
	description = "ARN for application logs"
	type = string
}

variable audit_log_arn {
	description = "ARN for audit logs"
	type = string
}

module constants {
	source = "../../constants"
}

locals {
	custom_domain = var.custom_domain == null ? null : "${var.custom_domain}.${var.root_domain}"
	has_custom_domain = local.custom_domain != null
	we_own_domain = contains(module.constants.route53_domains, var.root_domain)
	has_password = var.password != null
	is_vpc = var.vpc_id != null
	saml_enabled = var.saml_metadata != null
}

data aws_region current {}

data aws_caller_identity current {}

data aws_route53_zone zone {
	count = local.we_own_domain ? 1 : 0
	name = var.root_domain
	provider = aws.dns
}

data aws_vpc current {
	id = var.vpc_id
}

