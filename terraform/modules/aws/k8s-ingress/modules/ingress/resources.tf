resource helm_release ingress {
	chart = "${path.module}/helm"
	name = local.lb_name
	namespace = local.namespace
	values = [templatefile("${path.module}/templates/values.yaml", merge({
		is_external: var.is_external
		routes: var.routes
		certificate_arn: var.is_external ? join(",", [for route in var.routes : route.certificate_arn]) : ""
		name: local.lb_name
		listen_ports: local.port_map
		lb_attributes: local.lb_attributes
		ssl_policy: var.ssl_policy
		vpc_id: var.vpc_id
		is_dual_stack: var.is_dual_stack
	}, local.auth_config))]
}

# Likely to fail the first time, the helm release ends a bit before the LB is created; likely the polling interval of k8s LB controller
data aws_lb main {
	name = local.lb_name
	depends_on = [helm_release.ingress]
}

resource aws_route53_record cname {
	for_each = local.cname_map
	zone_id = data.aws_route53_zone.zone[each.value.root_domain].id
	provider = aws.dns
	name = each.value.domain
	type = "CNAME"
	ttl = "300"
	records = [data.aws_lb.main.dns_name]
}

module cognito_application {
	count = var.has_auth ? 1 : 0
	source = "../../../cognito-application"
	user_pool_id = local.user_pool_id
	identity_providers = ["Microsoft", "COGNITO"]
	domains = [for c in local.cname_map : c.domain]
	name = local.app_name
	providers = {
		aws : aws.cognito
	}
}
