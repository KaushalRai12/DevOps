resource aws_iam_service_linked_role ssm {
	aws_service_name = "ssm.amazonaws.com"
}

module patch {
	source = "./modules/patch"
	maintenance_time_zone = local.maintenance_tz
	scan_window_schedule = "cron(0 0 ? * MON-FRI *)"
	scan_window_duration = 2
	scan_window_cutoff = 1
	patch_window_schedule = "cron(0 2 ? * MON-FRI *)"
	patch_window_duration = 3
	patch_window_cutoff = 0
	role_arn = aws_iam_service_linked_role.ssm.arn
	logs_bucket = var.logs_bucket
}
