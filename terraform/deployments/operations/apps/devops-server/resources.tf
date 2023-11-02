module devops_server {
	source = "../../../../modules/apps/devops-server"
	providers = {
		aws.secrets = aws.secrets
	}
}
