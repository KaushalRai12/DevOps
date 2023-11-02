variable domain_suffix {
	type = string
}

variable redirect_guid {
	type = string
	default = null
}

//============ data
data aws_region current {}

//=========== outputs
output user_pool_id {
	value = aws_cognito_user_pool.operations.id
}

output saml_identifier {
	value = "urn:amazon:cognito:sp:${aws_cognito_user_pool.operations.id}"
}

output saml_reply_url {
	value = "https://${aws_cognito_user_pool_domain.operations.domain}.auth.${data.aws_region.current.name}.amazoncognito.com/saml2/idpresponse"
}

