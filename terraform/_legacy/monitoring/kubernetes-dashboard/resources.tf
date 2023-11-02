module "dev" {
	source = "./module"
}

module "prod" {
	source = "./module"
	providers = {
		helm = helm.prod
	}
}
