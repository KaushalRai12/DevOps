module aex_co_za {
	source = "../../../../../modules/aws/route-53-zone-records"
	zone_id = data.aws_route53_zone.zone.id

	# a_records = merge(local.a_records, local.gearsoft_a_records)
	a_records = merge(local.a_records)
	c_names = local.c_names
	ns = local.gearsoft_subdomains
	txt = local.txt_records
	srv = local.srv_records
	mx = local.mx_records
}
