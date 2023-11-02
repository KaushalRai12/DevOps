resource helm_release tftp {
	chart = "${path.module}/helm"
	name = var.service_name
	namespace = var.namespace

	values = [templatefile("${path.module}/templates/values.yaml", {
		service_name: var.service_name
		subnets: join(", ", var.subnets)
	})]
}

data aws_lb tftp {
	tags = {
		"kubernetes.io/service-name": "${var.namespace}/${var.service_name}"
	}
	depends_on = [helm_release.tftp]
}

module cname {
	source = "../../aws/dns-cname"
	domain_name = "${var.domain}.${var.root_domain}"
	target = data.aws_lb.tftp.dns_name
	root_domain = var.root_domain
}
