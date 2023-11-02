variable vpc_id {
	type = string
}

variable vpc_cidr {
	type = string
}

variable cluster_fqn {
	type = string
}

variable aws_profile {
	type = string
}

variable kube_context {
	type = string
}

variable eks_version {
	type = string
	default = "1.21"
}

variable node_security_group_ids {
	type = set(string)
}

variable integration_node_security_group_ids {
	type = set(string)
}

variable node_subnet_ids {
	type = list(string)
}

variable node_capacity_type {
	type = string
	default = "SPOT"
}

variable public_subnets {
	type = set(string)
}

variable integration_node_subnet_ids {
	type = list(string)
}

variable app_node_instance_types {
	type = list(string)
	default = ["t3.medium"]
}

variable app_nodes_quantity {
	type = number
	default = 2
}

variable app_nodes_capacity_type {
	type = string
	default = null
}

variable auto_scale_groups {
	type = set(string)
  default = []
}

variable devops_node_instance_types {
	type = list(string)
	default = ["t3.large"]
}

variable devops_nodes_capacity_type {
	type = string
	default = null
}

variable devops_nodes_quantity {
	type = number
	default = 2
}

variable integration_node_instance_types {
	type = list(string)
	default = ["t3.medium"]
}

variable integration_nodes_quantity {
	type = number
	default = 2
}

variable integration_nodes_capacity_type {
	type = string
	default = null
}

variable stable_devops_node_instance_types {
	type = list(string)
	default = ["t3.medium"]
}

variable stable_devops_nodes_quantity {
	type = number
	default = 0
}

variable stable_app_node_instance_types {
	type = list(string)
	default = ["t3.medium"]
}

variable stable_app_nodes_quantity {
	type = number
	default = 0
}

variable stable_integration_node_instance_types {
	type = list(string)
	default = ["t3.medium"]
}

variable stable_integration_nodes_quantity {
	type = number
	default = 0
}

variable k8s_namespaces {
	type = list(string)
}

variable key_prefix {
	type = string
	default = null
}

variable gitlab_secret_name {
	description = "Name of secret from which to draw gitlab passwords"
	type = string
	default = "gitlab_passwords"
}

variable gitlab_address {
	description = "Address of gitlab server"
	type = string
	default = "gitlab.vumaex.net"
}

variable devops_email {
	description = "Email address for devops mails"
	type = string
	default = "devops@aex.co.za"
}

// ======== Data

data aws_region current {}

data aws_caller_identity current {}

data aws_secretsmanager_secret_version gitlab {
	provider = aws.secrets
	secret_id = var.gitlab_secret_name
}

// ============ locals
locals {
	gitlab_registry_password = jsondecode(data.aws_secretsmanager_secret_version.gitlab.secret_string)["docker_registry_password"]
	key_prefix = var.key_prefix == null ? "" : "${var.key_prefix}-"
	app_nodes_capacity_type = coalesce(var.app_nodes_capacity_type, var.node_capacity_type)
	devops_nodes_capacity_type = coalesce(var.devops_nodes_capacity_type, var.node_capacity_type)
	integration_nodes_capacity_type = coalesce(var.integration_nodes_capacity_type, var.node_capacity_type)
}

module constants {
	source = "../constants"
}

//============= outputs
output cluster_name {
	value = aws_eks_cluster.eks.name
}

output node_role_arn {
	value = aws_iam_role.node_instance.arn
}

output cluster_security_group_id {
	value = aws_security_group.cluster_security_group.id
}
