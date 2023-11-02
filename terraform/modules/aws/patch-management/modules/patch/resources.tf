resource aws_ssm_patch_baseline ubuntu {
	name = "aex-ubuntu"
	description = "Ubuntu important patch baseline"
	operating_system = "UBUNTU"

	approval_rule {
		approve_after_days = 7

		patch_filter {
			key = "PRIORITY"
			values = ["Required", "Important"]
		}
	}
}

data aws_ssm_patch_baseline windows {
	owner = "AWS"
	name_prefix = "AWS-"
	operating_system = "WINDOWS"
	default_baseline = true
}

// Experimental - as example - not used
resource aws_ssm_patch_baseline windows {
	operating_system = "WINDOWS"
	name = "aex-windows"
	description = "Windows important patch baseline"

	approval_rule {
		approve_after_days = 7

		patch_filter {
			key = "CLASSIFICATION"
			values = ["CriticalUpdates", "SecurityUpdates"]
		}

		patch_filter {
			key = "MSRC_SEVERITY"
			values = ["Critical", "Important"]
		}
	}
}

# Linux Patch Group
resource aws_ssm_patch_group ubuntu {
	baseline_id = aws_ssm_patch_baseline.ubuntu.id
	patch_group = "ubuntu"
}

# Windows Patch Group
resource aws_ssm_patch_group windows_patch_group {
	baseline_id = data.aws_ssm_patch_baseline.windows.id
	patch_group = "windows"
}

# Scan Maintenance Window
resource aws_ssm_maintenance_window scan {
	count = local.scan_window_enabled ? 1 : 0
	name = "scan-Instances"
	cutoff = var.scan_window_cutoff
	description = "Maintenance window for scanning for patch compliance"
	duration = var.scan_window_duration
	schedule = var.scan_window_schedule
	schedule_timezone = var.maintenance_time_zone
}

# Patch Maintenance Window
resource aws_ssm_maintenance_window patch {
	count = local.patch_window_enabled ? 1 : 0
	name = "patch-Instances"
	cutoff = var.patch_window_cutoff
	description = "Maintenance window for applying patches"
	duration = var.patch_window_duration
	schedule = var.patch_window_schedule
	schedule_timezone = var.maintenance_time_zone
}

# Windows Scan Maintenance Windows Targets
resource aws_ssm_maintenance_window_target scan_default {
	count = local.scan_window_enabled ? 1 : 0
	window_id = aws_ssm_maintenance_window.scan[0].id
	resource_type = "INSTANCE"

	targets {
		key = "tag:aex/system/scan-updates"
		values = ["default"]
	}
}

# Windows Patch Maintenance Windows
resource aws_ssm_maintenance_window_target patch_default {
	count = local.patch_window_enabled ? 1 : 0
	window_id = aws_ssm_maintenance_window.patch[0].id
	resource_type = "INSTANCE"

	targets {
		key = "tag:aex/system/patch-updates"
		values = ["default"]
	}
}

# Maintenance Window Tasks
resource aws_ssm_maintenance_window_task scan {
	count = local.scan_window_enabled ? 1 : 0
	max_concurrency = 2
	max_errors = 1
	name = "scan-instances"
	priority = 1
	service_role_arn = local.task_role
	task_arn = "AWS-RunPatchBaseline"
	task_type = "RUN_COMMAND"
	window_id = aws_ssm_maintenance_window.scan[0].id

	targets {
		key = "WindowTargetIds"
		values = [
			aws_ssm_maintenance_window_target.scan_default[0].id,
		]
	}

	task_invocation_parameters {

		run_command_parameters {
			output_s3_bucket = var.logs_bucket
			output_s3_key_prefix = "scan"
			service_role_arn = local.task_role

			document_version = "$DEFAULT"
			timeout_seconds = 600
			cloudwatch_config {
				cloudwatch_output_enabled = true
			}

			parameter {
				name = "Operation"
				values = [
					"Scan",
				]
			}
			parameter {
				name = "RebootOption"
				values = [
					"RebootIfNeeded",
				]
			}

		}
	}
}

resource aws_ssm_maintenance_window_task patch {
	count = local.patch_window_enabled ? 1 : 0
	max_concurrency = 1
	max_errors = 1
	name = "patch-instances"
	priority = 1
	service_role_arn = local.task_role
	task_arn = "AWS-RunPatchBaseline"
	task_type = "RUN_COMMAND"
	window_id = aws_ssm_maintenance_window.patch[0].id

	targets {
		key = "WindowTargetIds"
		values = [
			aws_ssm_maintenance_window_target.patch_default[0].id,
		]
	}

	task_invocation_parameters {

		run_command_parameters {
			output_s3_bucket = var.logs_bucket
			output_s3_key_prefix = "patch"
			service_role_arn = local.task_role

			document_version = "$DEFAULT"
			timeout_seconds = 600

			parameter {
				name = "Operation"
				values = [
					"Install",
				]
			}
			parameter {
				name = "RebootOption"
				values = [
					"RebootIfNeeded",
				]
			}
		}
	}
}
