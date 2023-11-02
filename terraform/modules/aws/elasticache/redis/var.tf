variable cluster_fqn {
  type = string
}

variable cluster_env {
	description = "Cluster environment, e.g. dev, prod"
	type = string
}

variable cluster_name {
	description = "Name of the cluster"
	type = string
}

variable name {
	type = string
	default = null
}

variable node_type {
	type = string
  default = "cache.t3.small"
}

variable clustering_enabled {
	type = bool
	default = false
}

variable param_group {
	description = "The name of the parameter group to associate with this cache cluster."
	type = string
	default = null	
}

variable engine_version {
	type = string
  default = "3.2.10"
}

variable cluster_scaling_setting {
	type = object({
		replicas_per_node_group = number,
		num_cache_clusters = number,
	})
  	description = "Sets the amount of shards and read replicas per shard for a cluster"
	default = null
}

variable port {
	type = number
  default = 6379
}

variable apply_immediately {
	type = bool
  default = false
}

variable subnet_ids {
  type = set(string)
}

variable vpc_id {
	type = string
}

variable vpc_cidr {
	type = string
}

variable security_group_id {
	description = "Pass this in if you want to use an existing security group"
	type = string
	default = null
}

variable subnet_group {
	description = "Pass this in if you want to use an existing subnet group"
	type = string
	default = null
}

variable root_domain {
	description = "Root domain for friendly DNS records"
	type = string
	default = "vumaex.net"
}

variable availability_zone {
	description = "Availability Zone for the cache cluster. Will recreate resource if changed"
	type = string
	default = null
}

locals {
	cluster_name = var.name != null ? var.name : replace(var.cluster_fqn, "_", "-")
	param_group = var.param_group == null ? "default.redis${join(".", slice(split(".", var.engine_version), 0, 2))}" : var.param_group
	security_group_id = var.security_group_id == null ? aws_security_group.elasticache_security_group[0].id : var.security_group_id
	subnet_group = var.subnet_group == null ? aws_elasticache_subnet_group.redis_elasticache[0].name : var.subnet_group
	domain_prefix = var.cluster_env == "prod" ? "" : "${var.cluster_env}."
	domain_name = "${local.domain_prefix}redis.${var.cluster_name}.${var.root_domain}"
}

output security_group_id {
	description = "The security group that was used"
	value = local.security_group_id
}

output subnet_group {
	description = "The subnet group that was used"
	value = local.subnet_group
}

module constants {
	source = "../../constants"
}
