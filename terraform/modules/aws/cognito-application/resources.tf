resource aws_cognito_user_pool_client operations {
	name = var.name
	user_pool_id = var.user_pool_id
	access_token_validity = 12
	id_token_validity = 12
	explicit_auth_flows = ["ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
	prevent_user_existence_errors = "LEGACY"
	callback_urls = local.callback_urls
	allowed_oauth_flows_user_pool_client = true
	allowed_oauth_flows = ["code", "implicit"]
	allowed_oauth_scopes = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
	supported_identity_providers = var.identity_providers
	generate_secret = true
}

resource aws_cognito_user_pool_ui_customization operations {
	user_pool_id = var.user_pool_id
	client_id = aws_cognito_user_pool_client.operations.id

	css = file("${path.module}/templates/customization.css")
	image_file = filebase64("${path.module}/templates/aex-logo.jpg")
}
