resource aws_cloudwatch_log_group slow {
	name = "elastic_slow_logs_${var.cluster_fqn}"

	retention_in_days = 30

	lifecycle {
		create_before_destroy = true
		prevent_destroy       = false
	}
}

resource aws_cloudwatch_log_group audit {
	count = local.has_password ? 1 : 0
	name = "elastic_audit_logs_${var.cluster_fqn}"

	retention_in_days = 30

	lifecycle {
		create_before_destroy = true
		prevent_destroy       = false
	}
}

resource aws_cloudwatch_log_group application {
	name = "elastic_application_logs_${var.cluster_fqn}"

	retention_in_days = 30

	lifecycle {
		create_before_destroy = true
		prevent_destroy       = false
	}
}

data aws_iam_policy_document cloudwatch {

	statement {
		actions = [
			"logs:PutLogEvents",
			"logs:PutLogEventsBatch",
			"logs:CreateLogStream",
		]

		effect = "Allow"

		principals {
			type = "Service"
			identifiers = [
				"es.amazonaws.com"
			]
		}

		resources = ["arn:aws:logs:*"]
	}
}

resource aws_cloudwatch_log_resource_policy es {
	policy_name = "es-cloudwatch-log-${replace(var.cluster_fqn, "_", "-")}"
	policy_document = data.aws_iam_policy_document.cloudwatch.json
}

module elasticsearch {
	source = "./module"
	vpc_id = var.vpc_id
	ingress_cidr_blocks = var.ingress_cidr_blocks
	subnet_ids = slice(var.subnet_ids, 0, min(1, length(var.subnet_ids)))
	domain = replace("${var.cluster_fqn}_${var.domain_purpose}", "_", "-")
	dedicated_master_enabled = var.dedicated_master_enabled
	zone_awareness_enabled = var.zone_awareness_enabled
	node_instance_type = var.node_instance_type
	node_instance_count = var.node_instance_count
	ebs_options_volume_size = var.ebs_options_volume_size
	ebs_options_volume_type = var.ebs_options_volume_type
	password = var.password
	custom_domain = var.custom_domain
	root_domain = var.root_domain
	expose_to_vpn = var.expose_to_vpn
	saml_metadata = var.saml_env == null ? null : file("${path.module}/templates/saml-metadata-${var.saml_env}.xml")
	saml_master_user = var.saml_master_user
	saml_entity_id = var.saml_env == null ? null : local.saml_env_settings[var.saml_env].entity_id
	saml_master_backed_role = var.saml_env == null ? null : local.saml_env_settings[var.saml_env].master_role
	slow_log_arn = aws_cloudwatch_log_group.slow.arn
	audit_log_arn = local.has_password ? aws_cloudwatch_log_group.audit[0].arn : null
	app_log_arn = aws_cloudwatch_log_group.application.arn
	providers = {
		aws.dns = aws.dns
	}
}
