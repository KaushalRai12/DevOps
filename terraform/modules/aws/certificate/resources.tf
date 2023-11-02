resource aws_acm_certificate certificate {
	domain_name = var.domain_name
	validation_method = "DNS"

	tags = {
		Name = var.name
		Environment = var.cluster_environment
	}

	lifecycle {
		create_before_destroy = true
	}
}

resource aws_route53_record validation {
	provider = aws.dns
	for_each = {
		for item in slice([
			for dvo in aws_acm_certificate.certificate.domain_validation_options : {
				domain_name = dvo.domain_name
				name = dvo.resource_record_name
				record = dvo.resource_record_value
				type = dvo.resource_record_type
			}
		], 0, local.count_cap) : item.domain_name => item
	}

	allow_overwrite = true
	name = each.value.name
	records = [each.value.record]
	ttl = 60
	type = each.value.type
	zone_id = data.aws_route53_zone.zone[0].id
}

resource aws_acm_certificate_validation validation {
	count = local.count_cap
	certificate_arn = aws_acm_certificate.certificate.arn
	validation_record_fqdns = slice([for record in aws_route53_record.validation : record.fqdn], 0, local.count_cap)
}

