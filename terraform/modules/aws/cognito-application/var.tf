variable user_pool_id {
	type = string
}

variable name {
	type = string
}

variable domains {
	description = "List of supported domain for the app"
	type = set(string)
}

variable identity_providers {
	type = list(string)
}

locals {
	callback_urls = [for d in var.domains : "https://${d}/oauth2/idpresponse"]
}

output application_id {
	value = aws_cognito_user_pool_client.operations.id
}

output secret {
	value = aws_cognito_user_pool_client.operations.client_secret
}
