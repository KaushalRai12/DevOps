variable plan_name {
	description = "The display name of a backup plan"
	type = string
}

variable cluster_env {
	description = "Custer environment e.g. dev, prod"
	type = string
}

variable backup_type {
	description = "Backup type e.g. ebs, rds"
	type = string
}

variable rules {
	description = "A list of rules mapping rule configurations for a backup plan"
	type = any
	default = []
}

variable advanced_backup_settings {
	description = "An object that specifies backup options for each resource type"
	type = any
	default = []
}

variable backup_vault_events {
	description = "An array of events that indicate the status of jobs to back up resources to the backup vault."
	type = list(string)
	default = [
		"BACKUP_JOB_FAILED",
		"BACKUP_JOB_EXPIRED",
		"BACKUP_JOB_SUCCESSFUL",
	]
	/*
		All possibles:
		[
			"BACKUP_JOB_STARTED",
			"BACKUP_JOB_COMPLETED",
			"BACKUP_JOB_SUCCESSFUL",
			"BACKUP_JOB_FAILED",
			"BACKUP_JOB_EXPIRED",
			"RESTORE_JOB_STARTED",
			"RESTORE_JOB_COMPLETED",
			"RESTORE_JOB_SUCCESSFUL",
			"RESTORE_JOB_FAILED",
			"COPY_JOB_STARTED",
			"COPY_JOB_SUCCESSFUL",
			"COPY_JOB_FAILED",
			"RECOVERY_POINT_MODIFIED",
			"BACKUP_PLAN_CREATED",
			"BACKUP_PLAN_MODIFIED"
		]
	*/
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

locals {
	name = "${var.backup_type}-${var.cluster_env}"
	selection_tags = [
		{
			type = "STRINGEQUALS"
			key = "aex/backup/${var.backup_type}"
			value = var.cluster_env
		}
	]
}
