variable cluster_env {
	description = "Custer environment e.g. dev, prod"
	type = string
}

variable ebs_weekly_backup_ttl {
	description = "number of days for which to keep ebs weekly backups"
	type = number
	default = 90
}

variable rds_hourly_backup_ttl {
	description = "number of days for which to keep rds hourly backups"
	type = number
	default = 2
}

variable rds_daily_backup_ttl {
	description = "number of days for which to keep rds daily backups"
	type = number
	default = 14
}

variable rds_weekly_backup_ttl {
	description = "number of days for which to keep rds weekly backups"
	type = number
	default = 365
}
