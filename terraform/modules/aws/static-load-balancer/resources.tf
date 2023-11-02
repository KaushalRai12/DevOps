resource aws_lb aex_lb {
	name = "${replace(var.cluster_fqn, "_", "-")}-${var.load_balancer_name}"
	internal = false
	load_balancer_type = "application"
	security_groups = [var.security_group_id]
	subnets = var.subnets

	enable_deletion_protection = false
	enable_cross_zone_load_balancing = true

	idle_timeout = var.connection_timeout

	access_logs {
		bucket = var.logs_bucket
		enabled = true
	}

	tags = merge(tomap({
		"aex/primary-static" : true
		"aex/waf/protected" : var.vpc_id
	}), var.extra_tags)
}

resource aws_lb aex_lb_internal {
	name = "${replace(var.cluster_fqn, "_", "-")}-${var.load_balancer_name}-internal"
	internal = true
	load_balancer_type = "application"
	security_groups = [var.security_group_id]
	subnets = var.subnets
	idle_timeout = var.connection_timeout

	enable_deletion_protection = false
	enable_cross_zone_load_balancing = true

	access_logs {
		bucket = var.logs_bucket
		enabled = true
	}

	tags = merge(tomap({
		"aex/primary-static" : true
	}), var.extra_tags)
}

resource aws_lb_listener port_80_redirect {
	load_balancer_arn = aws_lb.aex_lb.arn
	port = 80
	protocol = "HTTP"

	default_action {
		type = "redirect"

		redirect {
			port = 443
			protocol = "HTTPS"
			status_code = "HTTP_301"
		}
	}
}

resource aws_lb_listener port_80_internal {
	load_balancer_arn = aws_lb.aex_lb_internal.arn
	port = 80
	protocol = "HTTP"

	default_action {
		type = "fixed-response"

		fixed_response {
			status_code = "404"
			content_type = "text/plain"
			message_body = "Route Not Found"
		}
	}
}

resource aws_lb_listener port_443 {
	load_balancer_arn = aws_lb.aex_lb.arn
	port = 443
	protocol = "HTTPS"
	ssl_policy = var.public_ssl_policy
	certificate_arn = var.default_certificate_arn

	default_action {
		type = "fixed-response"

		fixed_response {
			status_code = "404"
			content_type = "text/plain"
			message_body = "Route Not Found"
		}
	}
}

resource aws_lb_listener port_443_internal {
	load_balancer_arn = aws_lb.aex_lb_internal.arn
	port = 443
	protocol = "HTTPS"
	ssl_policy = "ELBSecurityPolicy-2016-08"
	certificate_arn = var.default_certificate_arn

	default_action {
		type = "fixed-response"

		fixed_response {
			status_code = "404"
			content_type = "text/plain"
			message_body = "Route Not Found"
		}
	}
}

//============= Routes
module route_fno_api {
	source = "./modules/lb_route"
	extra_external_domains = var.extra_fno_external_domains
	extra_internal_domains = []
	cluster_name = var.cluster_name
	domain_environment = var.domain_environment
	external_lb_dns = aws_lb.aex_lb.dns_name
	internal_lb_dns = aws_lb.aex_lb_internal.dns_name
	external_lb_arn_suffix = aws_lb.aex_lb.arn_suffix
	internal_lb_arn_suffix = aws_lb.aex_lb_internal.arn_suffix
	port_80_internal_arn = aws_lb_listener.port_80_internal.arn
	port_443_internal_arn = aws_lb_listener.port_443_internal.arn
	port_443_arn = aws_lb_listener.port_443.arn
	service_name = "fno"
	vpc_id = var.vpc_id
	target_port = var.fno_api_port
	targets = var.api_server_ids
	external_root_domain = var.external_root_domain
	internal_root_domain = var.internal_root_domain
	error_actions = var.error_actions
	warning_actions = var.warning_actions
	providers = {
		aws.dns = aws.dns
	}
}

module route_work_orders_api {
	source = "./modules/lb_route"
	extra_external_domains = var.extra_work_order_external_domains
	extra_internal_domains = []
	cluster_name = var.cluster_name
	domain_environment = var.domain_environment
	external_lb_dns = aws_lb.aex_lb.dns_name
	internal_lb_dns = aws_lb.aex_lb_internal.dns_name
	external_lb_arn_suffix = aws_lb.aex_lb.arn_suffix
	internal_lb_arn_suffix = aws_lb.aex_lb_internal.arn_suffix
	port_80_internal_arn = aws_lb_listener.port_80_internal.arn
	port_443_internal_arn = aws_lb_listener.port_443_internal.arn
	port_443_arn = aws_lb_listener.port_443.arn
	service_name = "work-orders"
	vpc_id = var.vpc_id
	target_port = var.work_orders_port
	targets = var.api_server_ids
	external_root_domain = var.external_root_domain
	internal_root_domain = var.internal_root_domain
	error_actions = var.error_actions
	warning_actions = var.warning_actions
	providers = {
		aws.dns = aws.dns
	}
}

module route_nms_api {
	source = "./modules/lb_route"
	extra_external_domains = var.extra_nms_external_domains
	extra_internal_domains = []
	count = signum(length(var.nms_server_ids))
	cluster_name = var.cluster_name
	domain_environment = var.domain_environment
	external_lb_dns = aws_lb.aex_lb.dns_name
	internal_lb_dns = aws_lb.aex_lb_internal.dns_name
	external_lb_arn_suffix = aws_lb.aex_lb.arn_suffix
	internal_lb_arn_suffix = aws_lb.aex_lb_internal.arn_suffix
	port_80_internal_arn = aws_lb_listener.port_80_internal.arn
	port_443_internal_arn = aws_lb_listener.port_443_internal.arn
	port_443_arn = aws_lb_listener.port_443.arn
	service_name = "nms"
	vpc_id = var.vpc_id
	target_port = var.nms_port
	targets = var.nms_server_ids
	external_root_domain = var.external_root_domain
	internal_root_domain = var.internal_root_domain
	error_actions = var.error_actions
	warning_actions = var.warning_actions
	providers = {
		aws.dns = aws.dns
	}
}

module route_events_api {
	source = "./modules/lb_route"
	extra_external_domains = var.extra_events_external_domains
	extra_internal_domains = []
	count = signum(length(var.nms_server_ids))
	cluster_name = var.cluster_name
	domain_environment = var.domain_environment
	external_lb_dns = aws_lb.aex_lb.dns_name
	internal_lb_dns = aws_lb.aex_lb_internal.dns_name
	external_lb_arn_suffix = aws_lb.aex_lb.arn_suffix
	internal_lb_arn_suffix = aws_lb.aex_lb_internal.arn_suffix
	port_80_internal_arn = aws_lb_listener.port_80_internal.arn
	port_443_internal_arn = aws_lb_listener.port_443_internal.arn
	port_443_arn = aws_lb_listener.port_443.arn
	service_name = "events"
	vpc_id = var.vpc_id
	target_port = var.events_port
	targets = var.api_server_ids
	external_root_domain = var.external_root_domain
	internal_root_domain = var.internal_root_domain
	error_actions = var.error_actions
	warning_actions = var.warning_actions
	providers = {
		aws.dns = aws.dns
	}
}

resource aws_lb_listener_rule lets_encrypt_portal_public {
	listener_arn = aws_lb_listener.port_80_redirect.arn

	action {
		type = "forward"
		target_group_arn = aws_lb_target_group.lets_encrypt_portal_public.arn
	}

	condition {
		path_pattern {
			values = ["/.well-known*"]
		}
	}
}

resource aws_lb_target_group lets_encrypt_portal_public {
	name = "lets-encrypt-portal-${var.domain_environment}"
	port = 80
	protocol = "HTTP"
	vpc_id = var.vpc_id
	target_type = "instance"

	health_check {
		matcher = "200-499"
	}

	lifecycle {
		create_before_destroy = true
	}
}

resource aws_lb_target_group_attachment lets_encrypt_portal_public {
	for_each = var.api_server_ids
	target_group_arn = aws_lb_target_group.lets_encrypt_portal_public.arn
	target_id = each.value
	port = 80
}
