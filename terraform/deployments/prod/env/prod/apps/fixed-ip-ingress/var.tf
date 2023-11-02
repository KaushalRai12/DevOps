module constants {
	source = "../../../../../../modules/aws/constants"
}

module constants_env {
	source = "../../modules/constants"
}

module constants_cluster {
	source = "../../../../modules/constants"
}

data aws_subnets nms_subnets {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
	tags = {
		"aex/nms" = "true"
	}
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

data aws_instances nms_workers {
	instance_tags = {
		"aex/purpose" = "nms-workers"
	}
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
}

data aws_db_instance prod_db {
	db_instance_identifier = "vumatel-prod"
}

data dns_a_record_set prod_db {
  host = data.aws_db_instance.prod_db.address
}

data aws_security_group nms_services_private {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
	tags = {
		"aex/nms" = "true"
	}
}

data aws_security_group prod_db_private {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
	tags = {
		"aex/data" = "true"
	}
}

data aws_lb alb_web_public {
	name = "${module.constants_env.cluster_fqn}-svc"
}

data aws_security_group alb_web_public {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
	tags = {
		"Name" = "${replace(module.constants_env.cluster_fqn, "-", "_")}_alb_security_group"
	}
}
