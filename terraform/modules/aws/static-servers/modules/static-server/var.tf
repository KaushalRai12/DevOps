variable cluster_env {
	type = string
}

variable cluster_name {
	type = string
}

variable ebs_optimized {
	type = bool
	default = true
}

variable disable_api_termination {
	type = bool
	default = false
}

variable monitoring {
	type = bool
	default = true
}

variable security_group_ids {
	type = set(string)
}

variable instance_type {
	type = string
}

variable server_name {
	type = string
}

variable key_name {
	type = string
}

variable subnet_ids {
	type = list(string)
}

variable ami {
	type = string
}

variable root_block_size {
	type = number
	default = 20
}

variable servers_per_function {
	type = number
}

variable user_data {
	type = string
	default = null
}

variable root_block_encrypted {
	type = bool
	default = true
}

variable requires_elastic_ip {
	type = bool
	default = false
}

variable domain {
	type = bool
	default = null
}

variable auto_domain {
	type = bool
	default = true
}

variable alternate_domains {
	type = list(string)
	default = []
}

variable extra_tags {
	description = "Additional tags"
	type = map(string)
	default = {}
}

variable patch_group {
	description = "Usually linux or windows; you can specify a custom group if you know what your doing"
	type = string
}

variable network_interface_id {
	description = "Optional id for a pre-defined network interface, us this if you want to custom config your NI"
	type = string
	default = null
}

variable private_ips {
	description = "Optional private IP addresses"
	type = list(string)
	default = null
}

variable custom_monitoring {
	description = "Enables polling for external monitoring - in our case Prometheus"
	type = bool
	default = true
}

variable root_domain {
	description = "Optional domain that will be the root of the server DNS"
	type = string
	default = "vumaex.blue"
}

locals {
	has_custom_nic = var.network_interface_id != null
	domain_prefix = var.cluster_env == "prod" || var.cluster_env == null ? "" : "${var.cluster_env}."
	backup_env = var.cluster_env == "prod" ? "prod" : "dev"
	root_domain = var.root_domain
	cluster_suffix = var.cluster_name == null ? "" : ".${var.cluster_name}"
	subnet_map = { for i, subnet in var.subnet_ids : substr(data.aws_availability_zones.available.names[i], -1, 1) => subnet if i < var.servers_per_function }
	// Note: this will fail if a domain is provided for a multi-AZ server deployment
	domains = { for az in keys(local.subnet_map) : var.domain != null  ? "${var.domain}${az =="a" ? "" : "-${az}"}" : replace("${local.domain_prefix}${var.server_name}${az =="a" ? "" : "-${az}"}${local.cluster_suffix}.${local.root_domain}", "_", "-") => az }
	alternate_domains = { for domain_az in setproduct(var.alternate_domains, keys(local.subnet_map)) : replace("${local.domain_prefix}${domain_az[0]}${domain_az[1] == "a" ? "" : domain_az[1]}${local.cluster_suffix}.${local.root_domain}", "_", "-") => domain_az[1] }
	all_domains = var.auto_domain ? merge(local.domains, local.alternate_domains) : {}
	calculated_tags = var.custom_monitoring ? tomap({ "aex/monitor" = "true" }) : {}
}

data aws_availability_zones available {
	state = "available"
}

module constants {
	source = "../../../constants"
}

data aws_route53_zone zone {
	name = local.root_domain
	provider = aws.dns
}

// ================ Outputs

output instance_ids {
	value = [for s in aws_instance.server : s.id]
}

output public_ips {
	value = [for s in aws_instance.server : s.public_ip]
}

output dns {
	value = [for a in aws_route53_record.a_record : a.fqdn]
}
