locals {
	env = "prod"
}

module constants_cluster {
	source = "../../../../modules/constants"
}

module constants_env {
	source = "../../modules/constants"
}
