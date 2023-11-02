moved {
	from = module.certificate
	to = module.ingress[0].module.certificate
}

moved {
	from = helm_release.ingresses
	to = module.ingress[0].helm_release.ingresses
}

moved {
	from = module.kibana_cname
	to = module.ingress[0].module.kibana_cname
}

moved {
	from = module.elastic_cname
	to = module.ingress[0].module.elastic_cname
}

moved {
	from = module.cognito_application
	to = module.ingress[0].module.cognito_application
}

moved {
	from = module.core
	to = module.ingress[0]
}
