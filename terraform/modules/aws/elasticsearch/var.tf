variable vpc_id {
	description = "set VPC Id when you want an in-vpc elastic instance. Not setting this will allow the instance to be publicly available, so should be accompanied by a password."
	type = string
	default = null
}

variable subnet_ids {
	description = "list of subnets that can be used for this instance; only applicable if using a vpn"
	type = list(string)
	default = []
}

variable cluster_fqn {
	description = "used to construct the domain name, along with domain_purpose"
	type = string
}

variable domain_purpose {
	type = string
	description = "used to suffix the ES domain"
	default = "data"
}

variable ingress_cidr_blocks {
	description = "Specify CIDR blocks that can access the ES instance"
	type = set(string)
	default = []
}

variable node_instance_count {
	description = "number of nudes in the cluster"
	type = number
	default = 1
}

variable node_instance_type {
	type = string
	default = "t3.medium.elasticsearch"
}

variable password {
	description = "Optional password for user 'admin'"
	type = string
	default = null
}

variable custom_domain {
	description = "Optional custom domain for elastic instance. Note: does not apply to Kibana"
	type = string
	default = null
}

variable root_domain {
	description = "If using a custom domain, you must specify the root domain"
	type = string
	default = "vumaex.net"
}

variable expose_to_vpn {
	description = "Set to true to allow 2-way access to/from AEx servers"
	type = bool
	default = false
}

variable saml_env {
	description = "Set to 'dev' or 'prod'. Set to null for no SAML"
	type = string
	default = null
}

variable saml_master_user {
	description = "Email (automationexchange.co.za) of master user that can perform admin operations"
	type = string
	default = null
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

variable zone_awareness_enabled {
	description = "master node EC2 instance type"
	type = bool
	default = false
}

variable dedicated_master_enabled {
	description = "Select to have dedicated master node"
	type = bool
	default = false
}

variable dedicated_master_type {
	description = "master node EC2 instance type"
	type = string
	default = "r5.large.search"
}

variable dedicated_master_count {
	description = "number of master nodes"
	type = number
	default = 3
}

locals {
	has_password = var.password != null
	saml_env_settings = {
		dev: {
			entity_id: "https://sts.windows.net/fc488917-6d09-4a8c-a741-1cca1bb2333d/"
			master_role: "f80206fa-9c3a-472b-a2d6-1d6b9935f5cc"
		}
		prod: {
			entity_id: "https://sts.windows.net/fc488917-6d09-4a8c-a741-1cca1bb2333d/"
			master_role: "55ebd93e-63e6-4c77-8cae-e7b76a00c642"
		}
	}
}
