variable k8s_namespace {
	type = string
}

variable cluster_name {
	type = string
}

variable external_services {
	description = "Optional list of external service names. These will be mapped to external domains with certificates."
	type = set(string)
	default = []
}

variable internal_services {
	description = "Optional list of internal service names. These will be mapped to internal HTTP domains."
	type = set(string)
	default = []
}

variable shared_services {
	description = "Optional list of shared service names. These will be mapped to internal HTTP domains and external domains with certificates."
	type = set(string)
	default = []
}

variable external_service_map {
	description = "List of external services"
	type = list(object({
		name = string
		service_name = string
		root_domain = string
		domain = string
		source_port = number
		target_port = number
	}))
	default = []
}

variable internal_service_map {
	description = "List of internal services"
	type = list(object({
		name = string
		service_name = string
		root_domain = string
		domain = string
		source_port = number
		target_port = number
		is_secure = bool
	}))
	default = []
}

variable internal_service_secure_default {
	description = "Default value of is_secure for internal routes"
	type = bool
	default = false
}

variable purpose {
	description = "Optional purpose suffix for ingress name"
	type = string
	default = null
}

variable domain_prefix {
	description = "Optional domain prefix; if not specified, it is derived from k8s_namespace. To wipe the prefix, specify empty string: \"\""
	type = string
	default = null
}

variable logs_bucket {
	description = "Set this to the log bucket name to enable LB logging"
	type = string
	default = null
}

variable ssl_policy {
	description = "Overridable LB SSL policy"
	type = string
	default = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}

module constants {
	source = "../constants"
}

variable has_auth {
	description = "Set to true to add cognito authentication"
	type = bool
	default = false
}

variable aws_profile {
	description = "Set to the currently used aws profile; only needed for cognito auth"
	type = string
	default = "vumatel-preprod"
}

variable internal_connection_timeout {
	description = "Time (in seconds) before a connection times out"
	type = number
	default = 3600
}

variable external_connection_timeout {
	description = "Time (in seconds) before a connection times out"
	type = number
	default = 120
}

variable vpc_id {
	description = "VPC ID"
	type = string
}

variable is_dual_stack {
	description = "Use dual stack IPs"
	type = bool
	default = false
}

variable extra_internal_ports {
	description = "Declare extra internal ports to listen on, e.g. `HTTP:80`"
	type = list(string)
	default = []
}

variable external_root_domain {
	description = "Root domain for friendly DNS records"
	type = string
	default = "vumaex.net"
}

variable internal_root_domain {
	description = "Root domain for friendly DNS records"
	type = string
	default = "vumaex.net"
}

locals {
	has_any_secure_internal_route = anytrue([for service in local.internal_service_map : service.is_secure])

	cluster_name = replace(var.cluster_name, "_", "-")
	ns_derived_prefix = var.k8s_namespace == "prod" ? "" : "${trimprefix(var.k8s_namespace, "aex-")}."
	domain_env_prefix = var.domain_prefix == "" ? "" : var.domain_prefix == null ? local.ns_derived_prefix : "${var.domain_prefix}."

	internal_root_domain = var.internal_root_domain
	external_root_domain = var.external_root_domain

	internal_services = setunion(var.internal_services, var.shared_services)
	external_services = setunion(var.external_services, var.shared_services)

	internal_service_map = concat([
	for service in local.internal_services : {
		name : service
		service_name : service
		domain : "${local.domain_env_prefix}${service}.${local.cluster_name}.${local.internal_root_domain}"
		target_port : 80
		source_port: var.internal_service_secure_default ? 443 : 80
		root_domain : local.internal_root_domain
		is_secure = var.internal_service_secure_default
	}
	],
	[
	for service in var.internal_service_map : merge(service, {
		name : coalesce(service.name, service.service_name)
		domain : "${coalesce(service.domain, "${local.domain_env_prefix}${service.service_name}")}.${coalesce(service.root_domain, local.internal_root_domain)}"
		source_port: coalesce(service.source_port, coalesce(service.is_secure, var.internal_service_secure_default) ? 443 : 80)
		root_domain: coalesce(service.root_domain, local.internal_root_domain)
		target_port = coalesce(service.target_port, 80)
		is_secure = coalesce(service.is_secure, var.internal_service_secure_default)
	})
	]
	)

	external_service_map = concat([
	for service in local.external_services : {
		name : service
		service_name : service
		source_port: 443
		domain : "${local.domain_env_prefix}${service}.${local.cluster_name}.${local.external_root_domain}"
		target_port : 80
		root_domain : local.external_root_domain
		is_secure = true
	}
	],
	[
	for service in var.external_service_map : merge(service, {
		name : coalesce(service.name, service.service_name)
		domain : "${coalesce(service.domain, "${local.domain_env_prefix}${service.service_name}")}.${coalesce(service.root_domain, local.external_root_domain)}"
		source_port: coalesce(service.source_port, 443)
		root_domain: coalesce(service.root_domain, local.external_root_domain)
		target_port = coalesce(service.target_port, 80)
		is_secure = true
	})
	]
	)
	cognito_region = data.aws_region.current.name == "af-south-1" ? "eu-west-1" : data.aws_region.current.name

	internal_routes = [for service in local.internal_service_map : merge(service, {
		certificate_arn: service.is_secure ? module.internal_certificate[service.name].certificate_arn : null
	})]
	external_routes = [for service in local.external_service_map : merge(service, {
		certificate_arn: service.is_secure ? module.certificate[service.name].certificate_arn : null
	})]
	external_routes_chunked = chunklist(local.external_routes, module.constants.max_lb_certificates - 1)
}

data aws_region current {}

output client_interface_lb_names {
	value = module.external_ingress[*].lb_name
}
