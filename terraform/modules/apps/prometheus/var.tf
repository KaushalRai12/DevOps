variable namespaces {
  description = "All namespaces to be covered by prometheus"
	type = list(string)
}

variable values {
	description = "Optional list of value overrides"
	type = list(string)
	default = []
}

variable aws_access_key {
	description = "Access Key for EC2 discovery"
	type = string
}

variable aws_secret_key {
	description = "Secret Key for EC2 discovery"
	type = string
}

variable vpc_id {
	description = "Cluster VPC ID"
	type = string
}

locals {
	smtp_username = "AKIA3ITRLR6RBWVDCBFJ"
	smtp_password = jsondecode(data.aws_secretsmanager_secret_version.smtp.secret_string)[local.smtp_username]
	slack_url = jsondecode(data.aws_secretsmanager_secret_version.slack.secret_string)["prometheus-webhook"]
}

data aws_secretsmanager_secret_version smtp {
	secret_id = "smtp"
	provider = aws.secrets
}

data aws_secretsmanager_secret_version slack {
	secret_id = "slack"
	provider = aws.secrets
}

data aws_region current {}

data aws_caller_identity current {}
