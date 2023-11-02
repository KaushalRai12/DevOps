resource helm_release freeradius_service {
	chart = "${path.module}/helm"
	name = "freeradius-service-${var.instance_name}"
	namespace = var.namespace

	values = [templatefile("${path.module}/templates/values.yaml", {
		instance_name: var.instance_name
    subnets: join(", ", var.subnets)
    ip_addresses: join(", ", var.ip_addresses)
	})]
}

data aws_lb freeradius {
	name = "freeradius-${var.instance_name}"
	depends_on = [helm_release.freeradius_service]
}

module freeradius_cname {
	source = "../../aws/dns-cname"
	domain_name = "${var.domain_name}.freeradius.${local.internal_domain}"
	target = data.aws_lb.freeradius.dns_name
	root_domain = local.internal_domain
	providers = {
		aws.dns = aws.dns
	}
}

resource aws_security_group_rule vumatel_vpn {
	type = "ingress"
	from_port = 1812
	to_port = 1813
	protocol = "UDP"
	description = "AEx VPN access"
	cidr_blocks = tolist(module.constants.vumatel_access_cidrs)
	security_group_id = data.aws_security_group.eks.id
}

resource aws_security_group_rule client_dc {
	count = signum(length(var.ingress_cidrs))
	type = "ingress"
	from_port = 1812
	to_port = 1813
	protocol = "UDP"
	description = "Client DC access"
	cidr_blocks = var.ingress_cidrs
	security_group_id = data.aws_security_group.eks.id
}



