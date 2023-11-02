variable bucket_name {
	type = string
}

data aws_caller_identity current {}

data template_file s3_bucket_policy {
	template = file("${path.module}/templates/bucket-policy.json.tpl")

	vars = {
		s3_bucket = aws_s3_bucket.bucket.arn
		account_id = data.aws_caller_identity.current.account_id
	}
}

output bucket_name {
	value = aws_s3_bucket.bucket.bucket
}

output bucket_arn {
	value = aws_s3_bucket.bucket.arn
}
