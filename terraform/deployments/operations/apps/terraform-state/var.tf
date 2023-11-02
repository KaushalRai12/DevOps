locals {
	lock_key_id = "LockID"
}

data template_file s3_bucket_policy {
	template = file("${path.module}/templates/bucket-policy.json.tpl")

	vars = {
		s3_bucket = aws_s3_bucket.state.arn
		dynamo_table = aws_dynamodb_table.lock.arn
	}
}

data template_file replication_policy {
	template = file("${path.module}/templates/replication-policy.json.tpl")

	vars = {
		source_bucket = aws_s3_bucket.state.arn
		destination_bucket = aws_s3_bucket.backup.arn
	}
}

module constants_cluster {
	source = "../../modules/constants"
}
