variable name_suffix {
	description = "Name suffix for the GenieACS deploy - typically and environment like 'stage'"
	type = string
	default = null
}

variable namespace {
	description = "K8s namespace for the GenieACS deploy"
	type = string
}

variable genie_values {
	description = "GenieACS chart values"
	type = string
	default = null
}

variable mongo_values {
	description = "Mongodb chart values"
	type = string
	default = null
}

variable nginx_values {
	description = "Nginx chart values"
	type = string
	default = null
}

locals {
	db_password_root = jsondecode(data.aws_secretsmanager_secret_version.genieacs.secret_string)["db-password-root"]
	db_password_genieacs = jsondecode(data.aws_secretsmanager_secret_version.genieacs.secret_string)["db-password-genieacs"]
	jwt_secret = jsondecode(data.aws_secretsmanager_secret_version.genieacs.secret_string)["jwt-secret"]
	name_suffix = var.name_suffix == null ? "" : "-${var.name_suffix}"
	db_server = "genieacs-db${local.name_suffix}"
}

data aws_secretsmanager_secret_version genieacs {
	secret_id = "genieacs"
	provider = aws.secrets
}

