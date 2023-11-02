resource aws_lb main {
	count = length(local.chunked_names)
	name = "portal-${var.domain_environment}-${count.index + 1}"
	internal = false
	load_balancer_type = "application"
	security_groups = [var.security_group_id]
	subnets = var.subnet_ids

	enable_deletion_protection = false
	enable_cross_zone_load_balancing = true

	access_logs {
		bucket = var.access_log_bucket
		enabled = true
	}

	tags = {
		"aex/lb/portal" : true
		"aex/waf/protected" : var.vpc_id
	}
}

resource aws_lb_listener port_80 {
	count = length(local.chunked_names)
	load_balancer_arn = aws_lb.main[count.index].arn
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

resource aws_lb_listener port_443 {
	count = length(local.chunked_names)
	load_balancer_arn = aws_lb.main[count.index].arn
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

module portal_routes {
	source = "../portal-routes"
	count = length(local.chunked_names)
	vpc_id = var.vpc_id
	portal_server_ids = var.portal_server_ids
	domain_environment = var.domain_environment
	cluster_name = var.cluster_name
	external_root_domain = var.external_root_domain
	internal_root_domain = var.internal_root_domain
	listener_arn = aws_lb_listener.port_443[count.index].arn
	lb_dns = aws_lb.main[count.index].dns_name
	lb_arn_suffix = aws_lb.main[count.index].arn_suffix
	portal_names = local.chunked_names[count.index]
	providers = {
		aws.dns = aws.dns
	}
}

resource aws_lb_listener_rule lets_encrypt {
	count = length(local.chunked_names)
	listener_arn = aws_lb_listener.port_80[count.index].arn

	action {
		type = "forward"
		target_group_arn = aws_lb_target_group.lets_encrypt[count.index].arn
	}

	condition {
		path_pattern {
			values = ["/.well-known*"]
		}
	}
}

resource aws_lb_target_group lets_encrypt {
	count = length(local.chunked_names)
	name = "lets-encrypt-portal-${var.domain_environment}-${count.index}"
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

resource aws_lb_target_group_attachment lets_encrypt {
	for_each = { for i, s in local.lb_instance_pairs : tostring(i) => { target : s[0], group_index : s[1] } }
	target_group_arn = aws_lb_target_group.lets_encrypt[each.value.group_index].arn
	target_id = each.value.target
	port = 80
}

