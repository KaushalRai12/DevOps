variable cluster_fqn {
	description = "Cluster fully qualified name"
	type = string
}

variable vpc_id {
	description = "VPC Id"
	type = string
}

module constants {
	source = "../../../constants"
}

data aws_security_group eks {
	filter {
		name = "vpc-id"
		values = [var.vpc_id]
	}
	tags = {
		"aws:eks:cluster-name" : var.cluster_fqn
		"kubernetes.io/cluster/${var.cluster_fqn}" : "owned"
	}
}
