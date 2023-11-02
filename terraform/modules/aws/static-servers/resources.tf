module fno_api {
	source = "./modules/static-server"
	servers_per_function = local.api_servers
	subnet_ids = var.services_private_subnet_ids
	server_name = "api"
	key_name = "${local.key_prefix}static-services"
	security_group_ids = [var.services_private_sg_id]
	disable_api_termination = var.disable_api_termination
	instance_type = var.api_server_instance_type
	ami = local.api_server_ami
	user_data = var.bootstrap_storage && local.efs_fqn != null ? replace(templatefile("${path.module}/templates/bootstrap-storage.sh", { efs_fqn = local.efs_fqn }), "\r\n", "\n") : null
	requires_elastic_ip = var.api_is_public
	root_block_encrypted = var.encrypt_volumes
	root_block_size = var.api_server_root_block_size
	cluster_env = var.cluster_env
	cluster_name = var.cluster_name
	patch_group = "ubuntu"
	extra_tags = {"aex/purpose": "api"}
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}

module fno_workers {
	source = "./modules/static-server"
	servers_per_function = local.worker_servers
	subnet_ids = var.services_private_subnet_ids
	server_name = "workers"
	key_name = "${local.key_prefix}static-services"
	security_group_ids = [var.services_private_sg_id]
	instance_type = var.workers_server_instance_type
	disable_api_termination = var.disable_api_termination
	ami = local.workers_server_ami
	user_data = var.bootstrap_storage && local.efs_fqn != null ? replace(templatefile("${path.module}/templates/bootstrap-storage.sh", { efs_fqn = local.efs_fqn }), "\r\n", "\n") : null
	root_block_size = var.workers_server_block_size
	requires_elastic_ip = var.api_is_public
	root_block_encrypted = var.encrypt_volumes
	cluster_env = var.cluster_env
	cluster_name = var.cluster_name
	patch_group = "ubuntu"
	extra_tags = {"aex/purpose": "workers"}
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}

module nms {
	source = "./modules/static-server"
	servers_per_function = local.nms_servers
	subnet_ids = var.nms_is_integration ? var.nms_subnet_ids : var.services_private_subnet_ids
	server_name = "nms"
	disable_api_termination = var.disable_api_termination
	key_name = "${local.key_prefix}nms-services"
	security_group_ids = var.nms_is_integration ? [var.nms_sg_id] : [var.services_private_sg_id]
	instance_type = var.nms_server_instance_type
	ami = local.nms_server_ami
  root_block_encrypted = local.nms_volume_encrypted
	requires_elastic_ip = var.nms_is_public
	cluster_env = var.cluster_env
	cluster_name = var.cluster_name
	patch_group = "ubuntu"
	extra_tags = {"aex/purpose": "nms"}
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}

module windows_portal {
	source = "./modules/static-server"
	servers_per_function = local.portal_servers
	subnet_ids = var.windows_portal_subnet_ids
	server_name = "portal"
	disable_api_termination = var.disable_api_termination
	key_name = "${local.key_prefix}windows-portal"
	security_group_ids = [var.services_private_sg_id]
	instance_type = var.windows_portal_instance_type
	root_block_size = var.windows_portal_server_block_size
	ami = local.windows_portal_ami
	requires_elastic_ip = var.portal_is_public
	root_block_encrypted = var.encrypt_volumes
	cluster_env = var.cluster_env
	cluster_name = var.cluster_name
	patch_group = "windows"
	extra_tags = {"aex/purpose": "portal"}
	custom_monitoring = var.custom_monitoring_windows
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}

module devops {
	servers_per_function = var.devops_server_ami == null ? 0 : 1
	source = "./modules/static-server"
	subnet_ids = var.services_private_subnet_ids
	server_name = "devops"
	key_name = "${local.key_prefix}devops"
	security_group_ids = [var.services_private_sg_id]
	disable_api_termination = var.disable_api_termination
	instance_type = var.devops_server_instance_type
	ami = var.devops_server_ami
	requires_elastic_ip = false
	root_block_encrypted = var.encrypt_volumes
	cluster_env = null
	cluster_name = var.cluster_name
	patch_group = "ubuntu"
	extra_tags = {"aex/purpose": "devops"}
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}

