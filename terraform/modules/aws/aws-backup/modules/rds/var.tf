variable cluster_env {
	description = "Custer environment e.g. dev, prod"
	type = string
}

variable backup_key_arn {
	description = "Key for backups"
	type = string
}

variable backup_role_arn {
	description = "Role for backups"
	type = string
}

variable sns_topic_arn {
	description = "SNS topic for notifications"
	type = string
}

variable hourly_backup_ttl {
	description = "number of days for which to keep hourly backups"
	type = number
	default = 2
}

variable daily_backup_ttl {
	description = "number of days for which to keep daily backups"
	type = number
	default = 14
}

variable weekly_backup_ttl {
	description = "number of days for which to keep weekly backups"
	type = number
	default = 365
}

data aws_region current {}

locals {
	backup_plan_name = "rds-${var.cluster_env}"
	rules = concat(
	var.hourly_backup_ttl == 0 ? [] : [
		{
			name = "hourly"
			schedule = "cron(0 5/1 ? * * *)"
			start_window = "65"
			completion_window = "190"
			enable_continuous_backup = true
			recovery_point_tags = {
				Name = "RDS Hourly Back Up Rule"
				Plan = local.backup_plan_name
				Schedule = "Hourly"
				Region = data.aws_region.current.name
			}

			lifecycle = {
				delete_after = var.hourly_backup_ttl
			}
		}
	],
	var.daily_backup_ttl == 0 ? [] : [
		{
			name = "daily"
			schedule = "cron(0 5 ? * * *)"
			start_window = "65"
			completion_window = "190"
			enable_continuous_backup = false
			recovery_point_tags = {
				Name = "RDS Daily Back Up Rule"
				Plan = local.backup_plan_name
				Schedule = "Daily"
				Region = data.aws_region.current.name
			}

			lifecycle = {
				delete_after = var.daily_backup_ttl
			}
		}
	],
	var.weekly_backup_ttl == 0 ? [] : [
		{
			name = "weekly"
			schedule = "cron(0 5 ? * 1 *)"
			start_window = "65"
			completion_window = "190"
			enable_continuous_backup = false
			recovery_point_tags = {
				Name = "RDS Weekly Back Up Rule"
				Plan = local.backup_plan_name
				Schedule = "Weekly"
				Region = data.aws_region.current.name
			}

			lifecycle = {
				delete_after = var.weekly_backup_ttl
			}
		}
	]
	)
}
