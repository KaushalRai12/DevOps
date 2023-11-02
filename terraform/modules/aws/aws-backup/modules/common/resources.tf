resource aws_backup_vault default {
	name = local.name
	kms_key_arn = var.backup_key_arn
}

resource aws_backup_plan default {
	name = var.plan_name

	dynamic rule {
		for_each = var.rules
		content {
			rule_name = lookup(rule.value, "name")
			target_vault_name = aws_backup_vault.default.name
			schedule = lookup(rule.value, "schedule", null)
			start_window = lookup(rule.value, "start_window", null)
			completion_window = lookup(rule.value, "completion_window", null)
			enable_continuous_backup = lookup(rule.value, "enable_continuous_backup", false)
			recovery_point_tags = lookup(rule.value, "recovery_point_tags")

			dynamic lifecycle {
				for_each = length(lookup(rule.value, "lifecycle")) == 0 ? [] : [lookup(rule.value, "lifecycle", {})]
				content {
					cold_storage_after = lookup(lifecycle.value, "cold_storage_after", 0)
					delete_after = lookup(lifecycle.value, "delete_after", 90)
				}
			}

			dynamic copy_action {
				for_each = length(lookup(rule.value, "copy_action", {})) == 0 ? [] : [lookup(rule.value, "copy_action", {})]
				content {
					destination_vault_arn = lookup(copy_action.value, "destination_vault_arn", null)

					dynamic lifecycle {
						for_each = length(lookup(copy_action.value, "lifecycle", {})) == 0 ? [] : [lookup(copy_action.value, "lifecycle", {})]
						content {
							cold_storage_after = lookup(lifecycle.value, "copy_action_cold_storage_after", 0)
							delete_after = lookup(lifecycle.value, "copy_action_delete_after", 90)
						}
					}
				}
			}
		}
	}

	dynamic advanced_backup_setting {
		for_each = var.advanced_backup_settings
		content {
			resource_type = lookup(advanced_backup_setting.value, "resource_type", "EC2")
			backup_options = lookup(advanced_backup_setting.value, "backup_options", null)
		}
	}
}

resource aws_backup_selection default {
	iam_role_arn = var.backup_role_arn
	name = local.name
	plan_id = aws_backup_plan.default.id

	dynamic selection_tag {
		for_each = local.selection_tags
		content {
			type = lookup(selection_tag.value, "type", null)
			key = lookup(selection_tag.value, "key", null)
			value = lookup(selection_tag.value, "value", null)
		}
	}
}

resource aws_backup_vault_notifications default {
	backup_vault_name = aws_backup_vault.default.name
	sns_topic_arn = var.sns_topic_arn
	backup_vault_events = var.backup_vault_events
}

