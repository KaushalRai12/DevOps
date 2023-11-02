variable log_bucket_name {
  description = "The full name of the log bucket"
	type = string
}

variable expiry_days {
	description = "Number of days before logs expire"
	type = number
	default = 14
}

data aws_elb_service_account main {}

data aws_caller_identity current {}

output bucket {
	value = aws_s3_bucket.lb_logs.bucket
}

output bucket_arn {
	value = aws_s3_bucket.lb_logs.arn
}
