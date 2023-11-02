resource aws_route53_record dns {
	zone_id = data.aws_route53_zone.zone.id
	provider = aws.dns
	name = var.domain_name
	type = "A"
	ttl = "300"
	records = [var.target]
}
