variable cluster_env {
	type = string
}

variable cluster_name {
	type = string
}

variable monitoring {
	type = bool
	default = true
}

variable servers_per_function {
	type = number
	default = 2
}

variable nms_servers {
	type = number
	default = null
}

variable api_servers {
	type = number
	default = null
}

variable worker_servers {
	type = number
	default = null
}

variable portal_servers {
	type = number
	default = null
}

variable services_private_subnet_ids {
	type = list(string)
}

variable services_private_sg_id {
	type = string
}

variable nms_subnet_ids {
	type = list(string)
}

variable windows_portal_subnet_ids {
	type = list(string)
}

variable nms_sg_id {
	type = string
}

variable efs_id {
	type = string
	default = null
}

variable encrypt_volumes {
	type = bool
	default = true
}

variable api_server_instance_type {
	type = string
	default = "t3.medium"
}

variable api_server_ami {
	type = string
	default = null
}

variable workers_server_instance_type {
	type = string
	default = "t3.xlarge"
}

variable workers_server_ami {
	type = string
	default = null
}

variable workers_server_block_size {
	type = number
	default = 20
}

variable api_server_root_block_size {
	type = number
	default = 20
}

variable windows_portal_server_block_size {
	type = number
	default = 50
}

variable windows_portal_ami {
	type = string
	default = null
}

variable windows_portal_instance_type {
	type = string
	default = "m4.xlarge"
}

variable nms_server_instance_type {
	type = string
	default = "t3.xlarge"
}

variable nms_server_ami {
	type = string
	default = null
}

variable nms_volume_encrypted {
	type = bool
	default = true
}

variable nms_is_integration {
	type = bool
	default = true
}

variable devops_server_ami {
	type = string
	default = null
}

variable devops_server_instance_type {
	type = string
	default = "t3.nano"
}

variable bootstrap_storage {
	type = bool
	default = true
}

variable key_prefix {
	type = string
	default = null
}

variable disable_api_termination {
	type = bool
	default = true
}

variable nms_is_public {
	type = bool
	default = false
}

variable api_is_public {
	type = bool
	default = false
}

variable portal_is_public {
	type = bool
	default = false
}

variable custom_monitoring_windows {
	description = "Tag the windows servers for detection by Prometheus monitoring"
	type = bool
	default = false
}

variable root_domain {
	description = "Optional domain that will be the root of the server DNS"
	type = string
	default = "vumaex.blue"
}

//============ locals
locals {
	efs_fqn = var.efs_id == null ? null : "${var.efs_id}.efs.${data.aws_region.current.name}.amazonaws.com"
	key_prefix = var.key_prefix == null ? "" : "${var.key_prefix}-"
	windows_portal_ami = coalesce(var.windows_portal_ami, module.ami.windows_2019)
	api_server_ami = coalesce(var.api_server_ami, module.ami.ubuntu_20_04_x86)
	workers_server_ami = coalesce(var.workers_server_ami, module.ami.ubuntu_20_04_x86)
	nms_server_ami = coalesce(var.nms_server_ami, module.ami.ubuntu_20_04_x86)
	nms_servers = coalesce(var.nms_servers, var.servers_per_function)
	nms_volume_encrypted = coalesce(var.nms_volume_encrypted, var.encrypt_volumes)
	api_servers = coalesce(var.api_servers, var.servers_per_function)
	worker_servers = coalesce(var.worker_servers, var.servers_per_function)
	portal_servers = coalesce(var.portal_servers, var.servers_per_function)
}

module ami {
	source = "../ami"
}

//================ data
data aws_region current {}

//================ output
output api_server_ids {
	value = module.fno_api.instance_ids
}

output nms_server_ids {
	value = module.nms.instance_ids
}

output portal_server_ids {
	value = module.windows_portal.instance_ids
}
