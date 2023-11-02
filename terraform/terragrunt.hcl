remote_state {
	backend = "s3"
	generate = {
		path = "backend.tf"
		if_exists = "overwrite_terragrunt"
	}
	config = {
		bucket = "vumatel-tf-state"
		key = path_relative_to_include()
		region = "af-south-1"
		profile = "vumatel-operations"
		dynamodb_table = "tf-state-lock"
		encrypt = true
	}
}

