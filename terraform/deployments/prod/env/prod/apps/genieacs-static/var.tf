locals {
	cluster_name = module.constants_cluster.cluster_name
	cluster_shortname = module.constants_cluster.cluster_shortname
	cluster_environment = "prod"
	cluster_fqn = "${local.cluster_name}_${local.cluster_environment}"
	domain_environment = "prod"
	ami_id = "ami-09f0252cc9f724947"
}

module constants_env {
	source = "../../modules/constants"
}

module constants_cluster {
	source = "../../../../modules/constants"
}

data aws_subnets public_subnets {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
	tags = {
		"aex/public" = "true"
	}
}

data aws_security_group db_private_security_group {
	name = "vumatel_prod_db_private_security_group"
}

data aws_security_groups genie_acs {
  filter {
    name = "vpc-id"
    values = [module.constants_env.vpc_id]
  }
  tags = {
    "Name" : "vumatel_prod_genie_acs_sg"
  }
}

data aws_lb static {
	name = "${replace(module.constants_env.cluster_fqn, "_", "-")}-svc"
}
