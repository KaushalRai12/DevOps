module this {
	source = "../../../../../../modules/apps/genieacs"
	name_suffix = "prod"
	namespace = "aex-prod"

	providers = {
		aws.secrets = aws.secrets
	}
}
