locals {
	kube_context = module.constants_env.k8s_context
}

module constants_env {
	source = "../../modules/constants"
}

module constants_cluster {
	source = "../../../../modules/constants"
}
