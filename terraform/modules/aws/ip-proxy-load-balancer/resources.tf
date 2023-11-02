module constants {
	source = "../constants"
}

resource aws_lb lb {
	name = "${replace(var.cluster_fqn, "_", "-")}-ip-${replace(var.purpose, "_", "-")}"
	internal = var.internal
	load_balancer_type = "network"
	subnets = var.subnets

	enable_deletion_protection = true
	enable_cross_zone_load_balancing = true

	tags = var.extra_tags
}

output load_balancer_arn {
	value = aws_lb.lb.arn
}
