locals {
	root_domain = module.constants.aex_legacy_domain
}

module constants {
	source = "../constants"
}

variable vpc_id {
	type = string
}

variable cluster_fqn {
	type = string
}

variable load_balancer_name {
  type = string
}

variable subnets {
	type = set(string)
}

variable api_server_ids {
	type = set(string)
}

variable nms_server_ids {
	type = set(string)
}

variable default_certificate_arn {
	description = "ARN of the default certificate - usually a wildcard"
	type = string
}

variable domain_environment {
	type = string
}

variable cluster_name {
	type = string
}

variable external_root_domain {
	description = "Root domain used for external routes"
	type = string
	default = "vumaex.net"
}

variable internal_root_domain {
	description = "Root domain used for internal routes"
	type = string
	default = "vumaex.internal"
}

variable extra_fno_external_domains {
	description = "Extra domains to be bound to the FNO endpoint"
	type = set(string)
	default = []
}

variable extra_nms_external_domains {
	description = "Extra domains to be bound to the NMS endpoint"
	type = set(string)
	default = []
}

variable extra_work_order_external_domains {
	description = "Extra domains to be bound to the WorkOrders endpoint"
	type = set(string)
	default = []
}

variable extra_events_external_domains {
	description = "Extra domains to be bound to the Events endpoint"
	type = set(string)
	default = []
}

variable security_group_id {
	type = string
}

variable logs_bucket {
	type = string
}

variable public_ssl_policy {
	description = "Override this to diminish the public security policy"
	type = string
	default = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
}

variable connection_timeout {
	description = "Time (in seconds) before a connection times out"
	type = number
	default = 60
}

variable nms_port {
	description = "NMS port"
	type = number
	default = 9293
}

variable events_port {
	description = "Event correlation port"
	type = number
	default = 9303
}

variable work_orders_port {
	description = "Work orders port"
	type = number
	default = 9297
}

variable fno_api_port {
	description = "FNO API port"
	type = number
	default = 9301
}

variable extra_tags {
	description = "Additional tags"
	type = map(string)
	default = {}
}

variable error_actions {
	description = "Array of actions, typically the ARNs of SNS topics, to trigger when an Error alarm changes state"
	type = set(string)
	default = null
}

variable warning_actions {
	description = "Array of actions, typically the ARNs of SNS topics, to trigger when a Warning alarm changes state"
	type = set(string)
	default = null
}

//========= Data Sources
data aws_region current {}

data aws_caller_identity current {}

data aws_elb_service_account main {}

data aws_vpc current {
	id = var.vpc_id
}

//============ output
output listener_443_arn {
	value = aws_lb_listener.port_443.arn
}

output load_balancer_dns {
	value = aws_lb.aex_lb.dns_name
}

output load_balancer_arn_suffix {
	value = aws_lb.aex_lb.arn_suffix
}

output listener_443_arn_internal {
	value = aws_lb_listener.port_443_internal.arn
}

output load_balancer_dns_internal {
	value = aws_lb.aex_lb_internal.dns_name
}
