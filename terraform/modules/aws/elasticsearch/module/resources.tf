resource aws_security_group elasticsearch {
	count = local.is_vpc ? 1 : 0
	name = "elasticsearch-${var.domain}"
	vpc_id = var.vpc_id
	tags = {
		Name = "elasticsearch-${var.domain}"
	}
}

resource aws_security_group_rule ingress_from_vpc {
	count = local.is_vpc ? 1 : 0
	type = "ingress"
	description = "VPC"
	from_port = 443
	to_port = 443
	protocol = "tcp"
	cidr_blocks = [data.aws_vpc.current.tags["aex/vpc/cidr"]]
	security_group_id = aws_security_group.elasticsearch[0].id
}

resource aws_security_group_rule ingress_from_vpn {
	count = var.expose_to_vpn && local.is_vpc ? 1 : 0
	type = "ingress"
	description = "VPN"
	from_port = 443
	to_port = 443
	protocol = "tcp"
	cidr_blocks = module.constants.vumatel_access_cidrs
	security_group_id = aws_security_group.elasticsearch[0].id
}

data aws_iam_policy_document access {
	statement {
		actions = ["es:*"]
		principals {
			identifiers = ["*"]
			type = "*"
		}
		effect = "Allow"

		resources = [
			"arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain}/*",
		]

		dynamic condition {
			for_each = range(signum(length(var.ingress_cidr_blocks)))
			content {
				test = "IPAddress"
				variable = "aws:SourceIp"
				values = var.ingress_cidr_blocks
			}
		}
	}
}

resource aws_elasticsearch_domain elasticsearch {
	domain_name = var.domain
	elasticsearch_version = "7.9"

	cluster_config {
		dedicated_master_enabled = var.dedicated_master_enabled
		dedicated_master_type = var.dedicated_master_type
		dedicated_master_count = var.dedicated_master_count

		instance_type = var.node_instance_type
		instance_count = var.node_instance_count

		zone_awareness_enabled = var.zone_awareness_enabled

		dynamic zone_awareness_config {
			for_each = range(var.zone_awareness_enabled ? 1 : 0)
			content {
				availability_zone_count = var.availability_zone_count
			}
		}
	}

	domain_endpoint_options {
		custom_endpoint_enabled = local.has_custom_domain
		custom_endpoint_certificate_arn = local.has_custom_domain ? module.certificate[0].certificate_arn : null
		custom_endpoint = local.custom_domain

		// If this has a password, HTTPS must be enabled
		enforce_https = local.has_password || var.enforce_https
		tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
	}


	encrypt_at_rest {
		enabled = var.encrypt_at_rest_enabled
	}

	node_to_node_encryption {
		enabled = var.node_to_node_encryption_enabled
	}

	ebs_options {
		ebs_enabled = var.ebs_options_ebs_enabled
		volume_size = var.ebs_options_volume_size
		volume_type = var.ebs_options_volume_type
	}

	dynamic log_publishing_options {
		for_each = range(local.has_password ? 1 : 0)
		content {
			log_type = "AUDIT_LOGS"
			cloudwatch_log_group_arn = var.audit_log_arn
		}
	}

	log_publishing_options {
		log_type = "INDEX_SLOW_LOGS"
		cloudwatch_log_group_arn = var.slow_log_arn
	}

	log_publishing_options {
		log_type = "SEARCH_SLOW_LOGS"
		cloudwatch_log_group_arn = var.slow_log_arn
	}

	log_publishing_options {
		log_type = "ES_APPLICATION_LOGS"
		cloudwatch_log_group_arn = var.app_log_arn
	}

	dynamic vpc_options {
		for_each = range(local.is_vpc ? 1 : 0)
		content {
			subnet_ids = var.subnet_ids
			security_group_ids = [aws_security_group.elasticsearch[0].id]
		}
	}

	dynamic advanced_security_options {
		for_each = range(local.has_password ? 1 : 0)
		content {
			enabled = local.has_password
			internal_user_database_enabled = local.has_password

			master_user_options {
				master_user_name = local.has_password ? "admin" : null
				master_user_password = var.password
			}
		}
	}

	advanced_options = {
		"rest.action.multi.allow_explicit_index" = "true"
		"override_main_response_version" = "false"
	}

	access_policies = data.aws_iam_policy_document.access.json

	tags = {
		Domain = var.domain
	}

}

resource aws_elasticsearch_domain_saml_options es_saml {
	# count = local.saml_enabled ? 1 : 0 # TODO: Re-add this once we're ready to migrate
	domain_name = aws_elasticsearch_domain.elasticsearch.domain_name
	saml_options {
		enabled = local.saml_enabled
		roles_key = "http://schemas.microsoft.com/ws/2008/06/identity/claims/groups"
		session_timeout_minutes = 120
		master_user_name = var.saml_master_user
		master_backend_role = var.saml_master_backed_role
		subject_key = ""
		idp {
			entity_id = var.saml_entity_id
			metadata_content = var.saml_metadata
		}
	}
}

module certificate {
	source = "../../certificate/modules/unwrapped"
	count = local.has_custom_domain ? 1 : 0
	domain_name = local.custom_domain
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}

resource aws_route53_record dns {
	count = local.we_own_domain && local.has_custom_domain ? 1 : 0
	zone_id = data.aws_route53_zone.zone[0].id
	provider = aws.dns
	name = local.custom_domain
	type = "CNAME"
	ttl = "300"
	records = [aws_elasticsearch_domain.elasticsearch.endpoint]
}
