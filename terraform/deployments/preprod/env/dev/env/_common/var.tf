locals {
	client_interface_routes = [
	for route in var.client_interfaces : {
		name = "client-interface-${route}"
		service_name = "client-interface"
		root_domain = module.constants.aex_i11l_client_facing_domain
		domain = "${var.env}.${route}.client-interface.${module.constants_cluster.cluster_shortname}"
		target_port = 80
	}
	]

	installer_routes = [
	for route in var.installers : {
		name = "installer-${route}"
		service_name = "installer-app"
		root_domain = module.constants.aex_i11l_client_facing_domain
		domain = "${var.env}.${route}.installer.${module.constants_cluster.cluster_shortname}"
		target_port = 80
	}
	]
}

variable client_interfaces {
	type = list(string)
}

variable installers {
	type = list(string)
}

variable portal_names {
	type = list(string)
}

variable env {
	description = "sub-environment e.g. stage, preprod"
	type = string
}

variable efs_id {
	type = string
}

variable logs_bucket {
	type = string
}

variable windows_portal_ami {
	description = "AMI for the windows portal server"
	type = string
	default = null
}

variable api_server_ami {
	description = "AMI for the linux API server"
	type = string
	default = null
}

variable api_server_instance_type {
	description = "Instance type for the linux API server"
	type = string
	default = "t3.medium"
}

variable nms_server_ami {
	description = "AMI for the linux NMS"
	type = string
	default = null
}

variable devops_server_ami {
	description = "AMI for the linux devops server"
	type = string
	default = null
}

variable encrypt_volumes {
	description = "Encrypt EBS volumes"
	type = bool
	default = true
}

variable internal_service_map {
	description = "List of internal services"
	type = list(object({
		name = string
		service_name = string
		root_domain = string
		domain = string
		source_port = number
		target_port = number
		is_secure = bool
	}))
	default = []
}

variable shared_services {
	description = "The shared services"
	type = list(string)
}
variable internal_services {
	description = "The internal services"
	type = list(string)
}
variable external_services {
	description = "The external services"
	type = list(string)
}

module constants {
	source = "../../../../../../modules/aws/constants"
}

module constants_env {
	source = "../../modules/constants"
}

module constants_cluster {
	source = "../../../../modules/constants"
}

/*
throws an error
data aws_efs_file_system efs {
	tags = {
		Name = "${module.env_constants.cluster_fqn}_efs"
	}
}
*/

data aws_security_group nms {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
	tags = {
		"aex/nms" : true
	}
}

data aws_subnets nms {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
	tags = {
		"aex/nms" : true
		"aex/az" : "a"
	}
}

data aws_security_group services {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
	tags = {
		"aex/service" : true
	}
}

data aws_subnets services {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
	tags = {
		"aex/service" : true
		"aex/az" : "a"
	}
}

data aws_subnets portal {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
	tags = {
		"aex/portal" : true
		"aex/az" : "a"
	}
}

data aws_subnets public {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
	tags = {
		"aex/public" : true
	}
}

data aws_acm_certificate default {
	domain = "*.${module.constants.aex_i11l_systems_domain}"
}

data aws_security_group lb {
	filter {
		name = "vpc-id"
		values = [module.constants_env.vpc_id]
	}
	tags = {
		Name : "${module.constants_cluster.cluster_name}_${module.constants_env.cluster_env}_alb_security_group"
	}
}

