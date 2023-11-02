resource aws_instance server {
	for_each = local.subnet_map
	ami = var.ami
	instance_type = var.instance_type
	key_name = var.key_name
	subnet_id = local.has_custom_nic ? null : each.value
	vpc_security_group_ids = local.has_custom_nic ? [] : var.security_group_ids
	associate_public_ip_address = !local.has_custom_nic # TODO: Add a setting that can override this
	monitoring = var.monitoring
	ebs_optimized = var.ebs_optimized
	disable_api_termination = var.disable_api_termination
	private_ip = var.private_ips == null ? null : var.private_ips[index(var.subnet_ids, each.value)]

	tags = merge({
		Name : "${replace(local.domain_prefix, ".", "_")}${var.server_name}_${each.key}"
		"aex/backup/ebs" : local.backup_env
		"aex/system/scan-updates" : "default"
		"aex/system/patch-updates" : "default"
	},
		local.calculated_tags,
		var.patch_group != null ? tomap({ "Patch Group" = var.patch_group }) : {},
		var.extra_tags,
	)

	root_block_device {
		delete_on_termination = false
		encrypted = var.root_block_encrypted
		volume_size = var.root_block_size
		volume_type = "gp2"
	}

	dynamic network_interface {
		for_each = range(local.has_custom_nic ? 1 : 0)
		content {
			network_interface_id = var.network_interface_id
			device_index = 0
		}
	}

	iam_instance_profile = module.constants.ec2_instance_profile

	volume_tags = {
		Name = "${replace(local.domain_prefix, ".", "_")}${var.server_name}"
	}

	user_data = var.user_data
}

resource aws_eip eip_allocation {
	for_each = var.requires_elastic_ip ? aws_instance.server : {}
	instance = each.value.id
	vpc = true

	tags = {
		Name = "${each.value.tags["Name"]}_eip"
	}
}

resource aws_route53_record a_record {
	for_each = local.all_domains
	zone_id = data.aws_route53_zone.zone.zone_id
	name = each.key
	type = "A"
	ttl = 600
	records = [
		aws_instance.server[each.value].private_ip
	]
	provider = aws.dns
}
