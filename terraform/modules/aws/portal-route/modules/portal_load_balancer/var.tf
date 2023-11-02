variable cluster_fqn {
	description = "cluster FQN"
	type = string
}

variable security_group_id {
	description = "Load Balancer security group"
	type = string
}

variable subnet_ids {
	description = "Load Balancer subnets"
	type = set(string)
}

variable access_log_bucket {
	description = "Logs bucket name"
	type = string
}

variable portal_names {
	description = "Set of portal names"
	type = list(string)
}

variable default_certificate_arn {
	description = "ARN of the default certificate - usually a wildcard"
	type = string
}

variable public_ssl_policy {
	description = "Override this to diminish the public security policy"
	type = string
	default = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}

variable vpc_id {
	type = string
}

variable portal_server_ids {
	type = set(string)
	description = "Instance Ids of the portal server"
}

variable domain_environment {
	description = "Environment name for the domain e.g. stage, preprod"
	type = string
}

variable cluster_name {
	description = "Name of the cluster e.g. dev, gcpud"
	type = string
}

variable external_root_domain {
	description = "Route public root domain"
	type = string
}

variable internal_root_domain {
	description = "Route private root domain"
	type = string
	default = "vumaex.net"
}

locals {
	chunked_names = chunklist(var.portal_names, module.constants.max_lb_certificates)
	lb_instance_pairs = tolist(setproduct(var.portal_server_ids, range(length(local.chunked_names))))
}

module constants {
	source = "../../../constants"
}
