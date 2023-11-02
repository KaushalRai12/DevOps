resource aws_route53_record a_record {
	for_each = {
		for i, ip in module.constants.vumatel_vmware_speed_test_ips:
			i => ip
	} 

	zone_id = data.aws_route53_zone.zone.zone_id
	name = "${each.value.zone}.open-speed-test.${module.constants_cluster.cluster_name}.${module.constants.aex_i11l_systems_domain}"
	type = "A"
	ttl = 300
	records = [each.value.ip]
	provider = aws.dns
}

data aws_route53_zone zone {
	name = module.constants.aex_i11l_systems_domain
	provider = aws.dns
}
