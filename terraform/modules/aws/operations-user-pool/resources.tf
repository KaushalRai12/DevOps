resource aws_cognito_user_pool operations {
	name = "aex-operations"
	auto_verified_attributes = ["email"]

	password_policy {
		minimum_length = 8
		require_lowercase = true
		require_numbers = true
		require_uppercase = true
		temporary_password_validity_days = 3
		require_symbols = false
	}

	username_configuration {
		case_sensitive = false
	}
}

resource aws_cognito_identity_provider microsoft {
	user_pool_id = aws_cognito_user_pool.operations.id
	provider_name = "Microsoft"
	provider_type = "SAML"

	provider_details = {
		MetadataFile = file("${path.module}/templates/operations-saml-metadata.xml")
		SLORedirectBindingURI = var.redirect_guid != null ? "https://login.microsoftonline.com/${var.redirect_guid}/saml2" : null
		SSORedirectBindingURI = var.redirect_guid != null ? "https://login.microsoftonline.com/${var.redirect_guid}/saml2" : null
	}

	attribute_mapping = {
		email = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
	}
}

resource aws_cognito_user_pool_domain operations {
	user_pool_id = aws_cognito_user_pool.operations.id
	domain = "${aws_cognito_user_pool.operations.name}-${var.domain_suffix}"
}

