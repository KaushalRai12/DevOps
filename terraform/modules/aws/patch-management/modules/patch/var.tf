variable maintenance_time_zone {
	description = "Timezone for schedule in Internet Assigned Numbers Authority (IANA) Time Zone Database format of the maintenance window"
	type = string
}

variable scan_window_schedule {
	type = string
	default = null
	description = "The schedule of the Scan Maintenance Window in the form of a cron or rate expression."
}

variable scan_window_cutoff {
	type = number
	default = null
	description = "The number of hours before the end of the Scan Maintenance Window that Systems Manager stops scheduling new tasks for execution."
}

variable scan_window_duration {
	type = number
	default = null
	description = "The duration of the Scan Maintenance Window in hours."
}

variable patch_window_schedule {
	type = string
	default = null
	description = "The schedule of the Patch Maintenance Window in the form of a cron or rate expression."
}

variable patch_window_cutoff {
	type = number
	default = null
	description = "The number of hours before the end of the Patch Maintenance Window that Systems Manager stops scheduling new tasks for execution."
}

variable patch_window_duration {
	type = number
	default = null
	description = "The duration of the Patch Maintenance Window in hours."
}

variable role_arn {
	description = "ARN for the system role"
	type = string
	default = null
}

variable logs_bucket {
	description = "Name of the S3 bucket to write logs"
	type = string
}

locals {
	scan_window_enabled = var.scan_window_schedule != null
	patch_window_enabled = var.patch_window_schedule != null
	task_role = var.role_arn != null ? var.role_arn : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/ssm.amazonaws.com/AWSServiceRoleForAmazonSSM"
}

data aws_caller_identity current {}
