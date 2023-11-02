module mem_used_percent_metric_alarm {
	source = "./modules/alarm"

	alarm_name = "memory-utilization-i-07e8f1b15a85521cb"
	alarm_description = "Memory Utilization is too high"
	comparison_operator = "GreaterThanOrEqualToThreshold"
	evaluation_periods = 1
	threshold = 80
	metric_name = "mem_used_percent"
	namespace = "AWS/EC2"
	period = 120
	dimensions = {
		ImageId = "ami-04902260ca3d33422"
		InstanceType = "t3.medium"
		InstanceId = "i-07e8f1b15a85521cb"
	}
	statistic = "Average"
}

module disk_used_percent_metric_alarm {
	source = "./modules/alarm"

	alarm_name = "disk_used_percent-i-07e8f1b15a85521cb"
	alarm_description = "Disk Usage is too high"
	comparison_operator = "GreaterThanOrEqualToThreshold"
	evaluation_periods = 1
	threshold = 80
	metric_name = "disk_used_percent"
	namespace = "AWS/EC2"
	period = 120
	dimensions = {
		ImageId = "ami-04902260ca3d33422"
		InstanceType = "t3.medium"
		InstanceId = "i-07e8f1b15a85521cb"
		device = "nvme0n1p1"
		fstype = "xfs"
		path = "/"
	}
	statistic = "Average"
}

module cpu_used_percent_metric_alarm {
	source = "./modules/alarm"

	alarm_name = "cpu-utilization-i-0e17c6524c7c134d5"
	alarm_description = "CPU Utilization is too high"
	comparison_operator = "GreaterThanOrEqualToThreshold"
	evaluation_periods = 2
	threshold = 80
	metric_name = "CPUUtilization"
	namespace = "AWS/EC2"
	period = 120
	dimensions = {
		InstanceId = "i-0e17c6524c7c134d5"
	}
	statistic = "Average"
}
