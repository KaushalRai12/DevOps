resource aws_cloudwatch_log_group waf_log_group {
	name = "aws-waf-logs-${local.cluster_fqn}"
	retention_in_days = var.log_group_retention_in_days

	tags = {
		Name : "aws-waf-logs-${local.cluster_fqn}"
	}
}

resource aws_wafv2_web_acl_logging_configuration waf_logs {
	log_destination_configs = [
		aws_cloudwatch_log_group.waf_log_group.arn
	]

	resource_arn = aws_wafv2_web_acl.web_acl.arn

	redacted_fields {
		query_string {}
	}
	redacted_fields {
		single_header {
			name = "authorization"
		}
	}
}

resource aws_wafv2_ip_set geo_whitelist {
	addresses = local.geo_whitelisted_ip_ranges
	ip_address_version = "IPV4"
	name = "geo-whitelist-${var.cluster_fqn}"
	scope = "REGIONAL"
	description = "Whitelisted Public IPs to access APIs and sites"
}

resource aws_wafv2_ip_set geo_blacklist {
	count = signum(length(local.geo_blacklisted_ip_ranges))
	addresses = local.geo_blacklisted_ip_ranges
	ip_address_version = "IPV4"
	name = "geo-blacklist-${var.cluster_fqn}"
	scope = "REGIONAL"
	description = "Blacklisted Public IPs to access APIs and sites"
}

resource aws_wafv2_ip_set not_rate_limited {
	count = signum(length(var.rate_limit_override_ip_ranges))
	addresses = var.rate_limit_override_ip_ranges
	ip_address_version = "IPV4"
	name = "not-rate-limited-${var.cluster_fqn}"
	scope = "REGIONAL"
	description = "IPs that can bypass rate limits"
}

resource aws_wafv2_web_acl web_acl {
	name = local.cluster_fqn
	scope = "REGIONAL"
	description = "WAF for cluster ${local.cluster_fqn}"

	custom_response_body {
		key = local.geo_blocked_response
		content = "Your IP address is not allowed"
		content_type = "TEXT_PLAIN"
	}

	custom_response_body {
		key = local.rate_limit_response
		content = "Too many requests"
		content_type = "TEXT_PLAIN"
	}

	default_action {
		allow {}
	}

	dynamic rule {
		for_each = range(signum(length(var.blocked_countries)))
		content {
			name = "country-blacklist"
			priority = 1
			action {
				block {
					custom_response {
						response_code = 403
						custom_response_body_key = local.geo_blocked_response
					}
				}
			}

			statement {
				geo_match_statement {
					country_codes = var.blocked_countries
				}
			}

			visibility_config {
				cloudwatch_metrics_enabled = true
				metric_name = "waf-geo-blocking"
				sampled_requests_enabled = false
			}
		}
	}

	dynamic rule {
		for_each = range(signum(length(aws_wafv2_ip_set.geo_blacklist)))
		content {
			name = "ip-blacklist"
			priority = 1
			action {
				block {
					custom_response {
						response_code = 403
						custom_response_body_key = local.geo_blocked_response
					}
				}
			}

			statement {
				ip_set_reference_statement {
					arn = one(aws_wafv2_ip_set.geo_blacklist).arn
				}
			}

			visibility_config {
				cloudwatch_metrics_enabled = true
				metric_name = "waf-ip-blocking"
				sampled_requests_enabled = false
			}
		}
	}

	dynamic rule {
		for_each = range(signum(length(var.allowed_countries)))
		content {
			name = "country-restriction"
			priority = 2
			action {
				block {
					custom_response {
						response_code = 403
						custom_response_body_key = local.geo_blocked_response
					}
				}
			}

			statement {
				not_statement {
					statement {
						or_statement {
							statement {
								geo_match_statement {
									country_codes = var.allowed_countries
								}
							}

							statement {
								ip_set_reference_statement {
									arn = aws_wafv2_ip_set.geo_whitelist.arn
								}
							}
						}
					}
				}
			}

			visibility_config {
				cloudwatch_metrics_enabled = true
				metric_name = "waf-geo-blocking"
				sampled_requests_enabled = false
			}
		}
	}

	dynamic rule {
		for_each = range(signum(var.rate_limit))
		content {
			name = "rate-limit"
			priority = 3

			action {
				block {
					custom_response {
						response_code = 429
						custom_response_body_key = local.rate_limit_response
					}
				}
			}

			statement {

				rate_based_statement {
					aggregate_key_type = "IP"
					limit = var.rate_limit

					dynamic scope_down_statement {
						for_each = range(signum(length(var.rate_limit_override_ip_ranges)))
						content {
							not_statement {
								statement {
									ip_set_reference_statement {
										arn = one(aws_wafv2_ip_set.not_rate_limited).arn
									}
								}
							}
						}
					}
				}
			}

			visibility_config {
				cloudwatch_metrics_enabled = true
				metric_name = "rate-limited"
				sampled_requests_enabled = false
			}
		}
	}

	rule {
		name = "fortinet-rules"
		priority = 4

		override_action {
			none {}
		}

		statement {
			managed_rule_group_statement {
				vendor_name = "Fortinet"
				name = "all_rules"

				excluded_rule {
					name = "Cross-Site-Scripting-01"
				}
				excluded_rule {
					name = "Cross-Site-Scripting-02"
				}
				excluded_rule {
					name = "Cross-Site-Scripting-03"
				}
				excluded_rule {
					name = "Database-Vulnerability-Exploit-01"
				}
				excluded_rule {
					name = "Database-Vulnerability-Exploit-02"
				}
				excluded_rule {
					name = "Database-Vulnerability-Exploit-03"
				}
				excluded_rule {
					name = "Malicious-Robot"
				}
				excluded_rule {
					name = "OS-Command-Injection-01"
				}
				excluded_rule {
					name = "OS-Command-Injection-02"
				}
				excluded_rule {
					name = "SQL-Injection-01"
				}
				excluded_rule {
					name = "SQL-Injection-02"
				}
				excluded_rule {
					name = "SQL-Injection-03"
				}
				excluded_rule {
					name = "Source-Code-Disclosure"
				}
				excluded_rule {
					name = "Web-Application-Injection-01"
				}
				excluded_rule {
					name = "Web-Application-Injection-02"
				}
				excluded_rule {
					name = "Web-Application-Vulnerability-Exploit-01"
				}
				excluded_rule {
					name = "Web-Application-Vulnerability-Exploit-02"
				}
				excluded_rule {
					name = "Web-Application-Vulnerability-Exploit-03"
				}
				excluded_rule {
					name = "Web-Application-Vulnerability-Exploit-04"
				}
				excluded_rule {
					name = "Web-Application-Vulnerability-Exploit-05"
				}
				excluded_rule {
					name = "Web-Application-Vulnerability-Exploit-06"
				}
				excluded_rule {
					name = "Web-Application-Vulnerability-Exploit-07"
				}
				excluded_rule {
					name = "Web-Scanner-01"
				}
				excluded_rule {
					name = "Web-Scanner-02"
				}
				excluded_rule {
					name = "Web-Scanner-03"
				}
				excluded_rule {
					name = "Web-Server-Vulnerability-Exploit-01"
				}
				excluded_rule {
					name = "Web-Server-Vulnerability-Exploit-02"
				}
				excluded_rule {
					name = "Web-Server-Vulnerability-Exploit-03"
				}
				excluded_rule {
					name = "Web-Server-Vulnerability-Exploit-04"
				}
			}
		}

		visibility_config {
			cloudwatch_metrics_enabled = true
			metric_name = "fortinet-rules"
			sampled_requests_enabled = false
		}
	}

	visibility_config {
		cloudwatch_metrics_enabled = true
		metric_name = "waf"
		sampled_requests_enabled = false
	}
}

resource aws_wafv2_web_acl_association elb_attachment {
	for_each = toset(data.aws_resourcegroupstaggingapi_resources.load_balancers.resource_tag_mapping_list[*].resource_arn)
	resource_arn = each.value
	web_acl_arn = aws_wafv2_web_acl.web_acl.arn
}


