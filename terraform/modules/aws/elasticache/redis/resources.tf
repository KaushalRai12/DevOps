resource aws_security_group elasticache_security_group {
	count = var.security_group_id == null ? 1 : 0
	vpc_id = var.vpc_id

	name = "${var.cluster_fqn}_elasticache_security_group"
	description = "Security group for elasticache"

	tags = {
		Name = "${var.cluster_fqn}_elasticache_security_group",
	}
}

module egress_all {
	count = var.security_group_id == null ? 1 : 0
	source = "../../networking/modules/egress-all"
	security_group_id = local.security_group_id
}

module ingress_vpc {
	count = var.security_group_id == null ? 1 : 0
	source = "../../networking/modules/ingress-vpc"
	security_group_id = local.security_group_id
	vpc_cidr = var.vpc_cidr
}

module ingress_operations {
	count = var.security_group_id == null ? 1 : 0
	source = "../../networking/modules/ingress-operations"
	security_group_id = local.security_group_id
	from_port = 6379
}

resource aws_elasticache_subnet_group redis_elasticache {
	count = var.subnet_group == null ? 1 : 0
	name = local.cluster_name
	subnet_ids = var.subnet_ids
	description = "Elasticache Subnet Groups"
}

resource aws_elasticache_cluster redis_elasticache {
	count = var.clustering_enabled ? 0 : 1
	cluster_id = local.cluster_name
	engine = "redis"
	node_type = var.node_type
	num_cache_nodes = 1
	parameter_group_name = local.param_group
	engine_version = var.engine_version
	port = var.port
	availability_zone = var.availability_zone
	apply_immediately = var.apply_immediately
	security_group_ids = [local.security_group_id]
	subnet_group_name = local.subnet_group
}

resource "aws_elasticache_replication_group" "redis_elasticache_cluster" {
	count                       = var.clustering_enabled ? 1 : 0
 	automatic_failover_enabled  = true
	engine                      = "redis"
	engine_version              = var.engine_version
	replication_group_id        = "${local.cluster_name}-cluster"
	description                 = "${local.cluster_name}-cluster"
	node_type                   = var.node_type
	replicas_per_node_group     = var.cluster_scaling_setting.replicas_per_node_group
	num_node_groups             = var.cluster_scaling_setting.num_cache_clusters
	parameter_group_name        = local.param_group
	apply_immediately           = var.apply_immediately
	security_group_ids          = [local.security_group_id]
	subnet_group_name           = local.subnet_group
	port                        = var.port
}

module friendly_domain {
	source = "../../dns-cname"
	domain_name = local.domain_name
	target = var.clustering_enabled ? aws_elasticache_replication_group.redis_elasticache_cluster[0].configuration_endpoint_address : aws_elasticache_cluster.redis_elasticache[0].cache_nodes[0].address
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}
