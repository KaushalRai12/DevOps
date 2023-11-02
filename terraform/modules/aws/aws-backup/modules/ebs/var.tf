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

variable daily_backup_ttl {
	description = "number of days for which to keep daily backups"
	type = number
	default = 14
}

variable weekly_backup_ttl {
	description = "number of days for which to keep weekly backups"
	type = number
	default = 90
}

data aws_region current {}

locals {
	backup_plan_name = "ebs-${var.cluster_env}"

	rules = concat(
	var.daily_backup_ttl == 0 ? [] : [
		{
			name = "daily"
			schedule = "cron(0 0 ? * * *)" #Cron Schedule
			start_window = "65" # The amount of time in minutes before beginning a backup.
			completion_window = "190" # The amount of time AWS Backup attempts a backup before canceling the job and returning an error
			enable_continuous_backup = true # Enable continuous backups for supported resources.This changes some of the cron schedules you can set
			recovery_point_tags = {
				Name = "EBS Daily Back Up Rule"
				Plan = local.backup_plan_name
				Schedule = "Daily"
				Region = data.aws_region.current.name
			}

			lifecycle = {
				cold_storage_after = 0
				delete_after = var.daily_backup_ttl
			}
		}
	],
	var.weekly_backup_ttl == 0 ? [] : [
		{
			name = "weekly"
			schedule = "cron(0 1 ? * 1 *)"
			start_window = "65"
			completion_window = "190"
			enable_continuous_backup = false
			recovery_point_tags = {
				Name = "EBS Daily Back Up Rule"
				Plan = local.backup_plan_name
				Schedule = "Weekly"
				Region = data.aws_region.current.name
			}

			lifecycle = {
				cold_storage_after = 0
				delete_after = var.weekly_backup_ttl
			}
		}
	]
	)
}
