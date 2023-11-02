resource aws_route53_record a_record {
	for_each = var.a_records
	zone_id = data.aws_route53_zone.zone.zone_id
	name = each.key
	type = "A"
	ttl = var.ttl
	records = [
		each.value
	]
}

resource aws_route53_record a_record_ttl {
	for_each = var.a_records_ttl
	zone_id = data.aws_route53_zone.zone.zone_id
	name = each.key
	type = "A"
	ttl = each.value[1]
	records = [
		each.value[0]
	]
}

resource aws_route53_record c_name {
	for_each = var.c_names
	zone_id = data.aws_route53_zone.zone.zone_id
	name = each.key
	type = "CNAME"
	ttl = var.ttl

	records = [
		each.value
	]
}

resource aws_route53_record c_name_ttl {
	for_each = var.c_names_ttl
	zone_id = data.aws_route53_zone.zone.zone_id
	name = each.key
	type = "CNAME"
	ttl = each.value[1]

	records = [
		each.value[0]
	]
}

resource aws_route53_record mx_record {
	for_each = var.mx
	zone_id = data.aws_route53_zone.zone.zone_id
	name = each.key
	type = "MX"
	ttl = var.ttl
	records = [
		each.value
	]
}

resource aws_route53_record txt_record {
	for_each = var.txt
	zone_id = data.aws_route53_zone.zone.zone_id
	name = each.key
	type = "TXT"
	ttl = var.ttl
	records = each.value
}

resource aws_route53_record srv_record {
	for_each = var.srv
	zone_id = data.aws_route53_zone.zone.zone_id
	name = each.key
	type = "SRV"
	ttl = var.ttl
	records = [
		each.value
	]
}

resource aws_route53_record ns_record {
	for_each = var.ns
	zone_id = data.aws_route53_zone.zone.zone_id
	name = each.key
	type = "NS"
	ttl = var.ns_ttl
	records = each.value
}
