variable index {
	description = "Optional index for indexed load balancers"
	type = number
	default = null
}

variable is_external {
	description = "Is the loadbalancer internet-facing?"
	type = bool
}

variable routes {
	description = "List of load balancer routes"
	type = list(object({
		name = string
		service_name = string
		root_domain = string
		domain = string
		source_port = number
		target_port = number
		certificate_arn = string
		is_secure = bool
	}))
}

variable k8s_namespace {
	description = "Kubernetes namespace"
	type = string
}

variable purpose {
	type = string
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

variable connection_timeout {
	description = "Time (in seconds) before a connection times out"
	type = number
	default = 60
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

variable extra_ports {
	description = "Declare extra ports to listen on, e.g. `HTTP:80`"
	type = list(string)
	default = []
}

variable root_domain {
	description = "Root domain for friendly DNS records"
	type = string
}

variable internal_root_domain {
	description = "Root domain for friendly DNS records"
	type = string
}

locals {
	namespace = "aex-${var.k8s_namespace}"
	cname_list = [for route in var.routes : route if contains(module.constants.route53_domains, route.root_domain)]
	cname_map = { for route in local.cname_list : route.name => route }
	name_suffix = var.purpose == null ? "" : "-${var.purpose}"
	index_suffix = var.index == null ? "" : "-${var.index}"
	lb_name = "k8s-${var.is_external ? "external" : "internal"}-${var.k8s_namespace}${local.name_suffix}${local.index_suffix}"
	derived_ports = [for route in var.routes : "{\"${var.is_external ? "HTTPS": "HTTP"}\": ${route.source_port}}"]

	root_domain = var.root_domain
	internal_root_domain = var.internal_root_domain
	route53_domains = distinct(concat(
		[for route in var.routes : route.root_domain if contains(module.constants.route53_domains, route.root_domain)],
		[local.root_domain, local.internal_root_domain],
	))
	route53_private_domains = ["vumaex.internal"]

	ports = distinct(concat(
		[for route in var.routes : "${route.is_secure ? "HTTPS" : "HTTP"}:${route.source_port}"],
		var.extra_ports,
		var.is_external ? ["HTTP:80"] : []
	))
	port_map = [
	for port in local.ports : {
		protocol : split(":", port)[0]
		port : split(":", port)[1]
	}
	]

	log_attributes = var.logs_bucket == null ? {} : tomap({
		"access_logs.s3.enabled" = "true"
		"access_logs.s3.bucket" = var.logs_bucket
	})
	other_attributes = tomap({
		"idle_timeout.timeout_seconds" = var.connection_timeout
	})
	lb_attributes = merge(local.log_attributes, local.other_attributes)

	app_suffix = var.purpose == null ? "" : "-${var.purpose}"
	user_pool_name = "aex-operations"
	user_pool_id = var.has_auth ? one(one(data.aws_cognito_user_pools.operations).ids) : ""
	app_name = "${local.user_pool_name}-k8s${local.app_suffix}"
	cognito_region = data.aws_region.current.name == "af-south-1" ? "eu-west-1" : data.aws_region.current.name
	same_auth_region = local.cognito_region == data.aws_region.current.name
	user_pool_domain = "${local.user_pool_name}-${trimprefix(var.aws_profile, "aex-")}.auth.${local.cognito_region}.amazoncognito.com"
	auth_config = tomap({
		user_pool_arn : var.has_auth ? one(one(data.aws_cognito_user_pools.operations).arns) : ""
		user_pool_client_id : var.has_auth ? one(module.cognito_application).application_id : ""
		user_pool_domain : var.has_auth ? local.user_pool_domain : ""
		auth_type : !var.has_auth ? "none" : local.same_auth_region ? "cognito" : "oidc"
		oidc_issuer : "https://cognito-idp.${local.cognito_region}.amazonaws.com/${local.user_pool_id}"
		oidc_auth_endpoint : "https://${local.user_pool_domain}/oauth2/authorize"
		oidc_token_endpoint : "https://${local.user_pool_domain}/oauth2/token"
		oidc_info_endpoint : "https://${local.user_pool_domain}/oauth2/userInfo"
		oidc_client_id : var.has_auth ? one(module.cognito_application).application_id : ""
		oidc_client_secret : var.has_auth ? one(module.cognito_application).secret : ""
	})

	/*
		Issuer: https://cognito-idp.eu-west-3.amazonaws.com/[pool-id] (make sure to use pool-id and not pool-name)
		Authorization endpoint: https://[pool-name].auth.eu-west-3.amazoncognito.com/oauth2/authorize
	Token endpoint: https://[pool-name].auth.eu-west-3.amazoncognito.com/oauth2/token
	User info endpoint: https://[pool-name].auth.eu-west-3.amazoncognito.com/oauth2/userInfo
	*/

}

module constants {
	source = "../../../constants"
}

data aws_region current {}

data aws_route53_zone zone {
	for_each = toset(local.route53_domains)
	name = each.value
	provider = aws.dns
	private_zone = contains(local.route53_private_domains, each.value)
}

output lb_name {
	value = local.lb_name
}

data aws_cognito_user_pools operations {
	count = var.has_auth ? 1 : 0
	name = local.user_pool_name
	provider = aws.cognito
}
