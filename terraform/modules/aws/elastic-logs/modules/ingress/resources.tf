module certificate {
	source = "../../../certificate/modules/unwrapped"
	domain_name = local.kibana_domain
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}

resource helm_release ingresses {
	name = "${var.elastic_prefix}-${var.suffix}-ingresses"
	chart = "${path.module}/helm"
	namespace = local.namespace

	set {
		name = "certificateArn"
		value = module.certificate.certificate_arn
	}

	set {
		name = "name"
		value = var.kibana_name
	}

	set {
		name = "loadBalancerName"
		value = local.kibana_name
	}

	set {
		name = "domainName"
		value = local.kibana_domain
	}

	dynamic set {
		for_each = range(var.is_internal ? 1 : 0)
		content {
			name = "isInternal"
			value = "true"
		}
	}
}

data aws_lb kibana {
	name = local.kibana_name
	depends_on = [helm_release.ingresses]
}

module kibana_cname {
	source = "../../../dns-cname/modules/unwrapped"
	domain_name = local.kibana_domain
	target = data.aws_lb.kibana.dns_name
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}

data aws_lb elastic {
	tags = {
		"kubernetes.io/service-name" : "${local.namespace}/${var.elastic_name}"
		"kubernetes.io/cluster/${var.eks_cluster_name}" : "owned"
	}
	// not really, but prevents an error on first time
	depends_on = [helm_release.ingresses]
}

module elastic_cname {
	source = "../../../dns-cname/modules/unwrapped"
	domain_name = local.elastic_domain
	target = data.aws_lb.elastic.dns_name
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}
