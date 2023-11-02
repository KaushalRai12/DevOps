module certificate {
	source = "../../../certificate/modules/unwrapped"
	domain_name = replace(var.domain, "_", "-")
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}

resource aws_lb_listener_certificate listener_certificate {
	listener_arn = data.aws_lb_listener.static_443.arn
	certificate_arn = module.certificate.certificate_arn
}

resource aws_route53_record dns {
	zone_id = data.aws_route53_zone.zone.id
	provider = aws.dns
	name = replace(var.domain, "_", "-")
	type = "CNAME"
	ttl = "300"
	records = [var.target_override == null ? data.aws_lb.dns.dns_name : var.target_override]
}
