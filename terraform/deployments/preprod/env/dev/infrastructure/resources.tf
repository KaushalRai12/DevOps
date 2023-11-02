module logs {
	source = "../../../../../modules/aws/log-bucket"
	log_bucket_name = module.constants_env.logs_bucket
}

module vpc {
	source = "../../../../../modules/aws/vpc"
	cluster_fqn = local.cluster_fqn
	vpc_cidr = local.vpc_cidr
	logs_bucket_arn = module.logs.bucket_arn
}

module networking {
	source = "../../../../../modules/aws/networking"
	cluster_fqn = local.cluster_fqn
	vpc_cidr = local.vpc_cidr
	vpc_id = module.vpc.vpc_id
	integration_cidr = local.integration_cidr
	vpn_gateway_id = module.vpc.vpn_gateway_id
	shared_nat_gateway = true
}

module transit_gateway {
	source = "../../../../../modules/aws/transit-gateway/attached"
	cluster_fqn = local.cluster_fqn
	vpc_id = module.vpc.vpc_id
	vpc_cidr = local.vpc_cidr
	subnet_ids = module.networking.private_subnet_ids
	extra_vpn_routes = module.constants_cluster.rosebank_nms_routes
	providers = {
		aws.transit = aws.transit
	}
}

module direct_connect_attachment {
	source = "../../../../../modules/aws/vumatel-direct-connect/association"
	vpc_cidr = local.vpc_cidr
	gateway_id = data.aws_dx_gateway.transit.id
	vpn_gateway_id = module.vpc.vpn_gateway_id
	providers = {
		aws.transit = aws.transit
	}	
}

module operations_routes {
	source = "../../../../../modules/aws/reflex-vpn-routing/modules/operations"
	vpc_id = module.vpc.vpc_id
	transit_gateway_id = module.transit_gateway.transit_gateway_id
	vpc_cidr = local.vpc_cidr
	providers = {
		aws.transit = aws.transit
		aws.operations = aws.operations
	}
}

resource aws_security_group public_load_balancers {
	vpc_id = module.vpc.vpc_id

	name = "${local.cluster_fqn}_alb_security_group"
	description = "Security group for all application load balancers"

	tags = {
		Name = "${local.cluster_fqn}_alb_security_group"
	}
}

module all_443_ingress {
	source = "../../../../../modules/aws/networking/modules/ingress-public"
	description = "All public ingress to ports 443 & 80"
	ports = [443, 80]
	security_group_id = aws_security_group.public_load_balancers.id
}

module load_balancer_all_egress {
	source = "../../../../../modules/aws/networking/modules/egress-all"
	security_group_id = aws_security_group.public_load_balancers.id
}

module eks {
	source = "../../../../../modules/aws/eks"
	cluster_fqn = local.cluster_fqn
	aws_profile = local.aws_profile
	node_subnet_ids = module.networking.eks_node_subnet_ids
	public_subnets = module.networking.public_subnet_ids
	integration_node_subnet_ids = module.networking.eks_integration_node_subnet_ids
	node_security_group_ids = [module.networking.eks_node_security_group_id]
	integration_node_security_group_ids = [module.networking.eks_integration_security_group_id]
	vpc_id = module.vpc.vpc_id
	vpc_cidr = local.vpc_cidr
	k8s_namespaces = ["stage", "preprod", "uat"]
	kube_context = module.constants_env.k8s_context
	app_nodes_quantity = 1
	app_node_instance_types = ["t3.large"]
	devops_nodes_quantity = 2
	devops_node_instance_types = ["t3.large"]
	integration_nodes_quantity = 1
	stable_devops_nodes_quantity = 1
	stable_devops_node_instance_types = ["t3.xlarge"]
	gitlab_secret_name = "gitlab"
	devops_email = module.constants.devops_email
	//auto_scale_groups = ["devops"]  avoid auto-scale until we have correctly setup resources
	providers = {
		aws.secrets = aws.operations
	}
}

module storage {
	source = "../../../../../modules/aws/storage"
	cluster_fqn = local.cluster_fqn
	cluster_name = local.cluster_short_name
	cluster_env = local.cluster_environment
	root_domain = module.constants.aex_i11l_systems_domain
	domain_env = "prod"
	deploy_databases = true
	portal_sql_password = local.mssql_central_password
	db_subnet_group_name = module.networking.db_subnet_group_name
	db_security_group_id = module.networking.db_security_group_id
	efs_subnet_ids = module.networking.static_services_subnet_ids
	efs_allowed_source_group_ids = [module.networking.static_services_security_group_id]
	vpc_id = module.vpc.vpc_id
	db_instance_type = "db.m5.large"
	rds_time_zone = "South Africa Standard Time"
	deploy_efs = false // no need - workers and api on the same box
	expose_to_vpn = true
	auto_minor_version_upgrade = true
	logs_bucket_arn = module.logs.bucket_arn
	log_bucket_name = module.constants_env.logs_bucket
	providers = {
		aws.dns = aws.operations
	}
}

module elasticsearch {
	source = "../../../../../modules/aws/elasticsearch"
	subnet_ids = module.networking.db_subnet_ids
	vpc_id = module.vpc.vpc_id
	cluster_fqn = local.cluster_fqn
	expose_to_vpn = true
	password = local.elastic_data_password
	custom_domain = "elastic-data.dev"
	saml_env = null
	root_domain = module.constants.aex_i11l_systems_domain
	providers = {
		aws.dns = aws.operations
	}
}

module elasticache {
	source = "../../../../../modules/aws/elasticache/redis"
	subnet_ids = module.networking.private_subnet_ids
	vpc_id = module.vpc.vpc_id
	vpc_cidr = local.vpc_cidr
	cluster_env = "prod"
	cluster_name = local.cluster_short_name
	cluster_fqn = local.cluster_fqn
	engine_version = "7.0"
	root_domain = module.constants.aex_i11l_systems_domain
	availability_zone = module.constants_cluster.aws_preferred_az
	providers = {
		aws.dns = aws.operations
	}
}

module "elasticache_parameter_group" {
  source = "../../../../../modules/aws/elasticache/parameter_group"

  name        = "sidekiq"
  family      = "redis7"
  description = "sidekiq parameter group for Redis7.0 with cluster mode off"
  parameters = [
    {
      	name  = "cluster-enabled"
      	value = "no"
    },
	{
		name = "maxmemory-policy"	
		value = "noeviction"
	}
  ]
}

module elasticache_nms_sidekiq {
	source = "../../../../../modules/aws/elasticache/redis"
	node_type = "cache.t3.small"
	subnet_ids = module.networking.private_subnet_ids
	param_group = module.elasticache_parameter_group.name
	cluster_name = "${local.cluster_short_name}-sidekiq"
	name = "${local.cluster_short_name}-sidekiq"
	cluster_env = local.cluster_environment
	vpc_id = module.vpc.vpc_id
	vpc_cidr = local.vpc_cidr
	cluster_fqn = "${local.cluster_fqn}_sidekiq"
	engine_version = "7.0"
	root_domain = module.constants.aex_i11l_systems_domain
	availability_zone = module.constants_cluster.aws_preferred_az
	providers = {
		aws.dns = aws.operations
	}
}

module backup {
	source = "../../../../../modules/aws/aws-backup"
	cluster_env = "dev"
	ebs_weekly_backup_ttl = 60
	rds_hourly_backup_ttl = 0
	rds_daily_backup_ttl = 7
	rds_weekly_backup_ttl = 60
}

module aws_cloudtrail {
 source = "../../../../../modules/aws/cloudtrail"
 cluster_name = local.cluster_name
 org_prefix = "vumatel"
}
