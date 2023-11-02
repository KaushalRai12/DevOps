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
	has_private_nat = true # For radius
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

module storage {
	source = "../../../../../modules/aws/storage"
	cluster_fqn = local.cluster_fqn
	cluster_name = local.cluster_shortname
	deploy_databases = true
	portal_sql_password = local.portal_sql_password
	db_security_group_id = module.networking.db_security_group_id
	db_subnet_group_name = module.networking.db_subnet_group_name
	efs_subnet_ids = module.networking.static_services_subnet_ids
	efs_allowed_source_group_ids = [module.networking.static_services_security_group_id]
	vpc_id = module.vpc.vpc_id
	max_allocated_storage = 300
	expose_to_vpn = true
	cluster_env = local.cluster_environment
	# Run a terraform apply in prod/env/prod/apps/fixed-ip-ingress after changing this
	db_instance_type = "db.m5.2xlarge"
	db_storage_type = "gp2" // should this be io1 ?
	rds_time_zone = "South Africa Standard Time"
	logs_bucket_arn = module.logs.bucket_arn
	log_bucket_name = module.constants_env.logs_bucket
	providers = {
		aws.dns = aws.dns
	}
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

module reflex_vpn_routes {
	source = "../../../../../modules/aws/reflex-vpn-routing"
	vpc_id = module.vpc.vpc_id
	transit_gateway_id = module.transit_gateway.transit_gateway_id
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

module backup {
	source = "../../../../../modules/aws/aws-backup"
	cluster_env = "prod"
}

module static_servers {
	source = "../../../../../modules/aws/static-servers"
	services_private_subnet_ids = module.networking.static_services_subnet_ids
	services_private_sg_id = module.networking.static_services_security_group_id
	nms_subnet_ids = module.networking.nms_subnet_ids
	nms_sg_id = module.networking.nms_security_group_id
	windows_portal_subnet_ids = module.networking.windows_subnet_ids
	disable_api_termination = true
	windows_portal_ami = "ami-05b229aac51b7c785"
	windows_portal_instance_type = "m5.large"
	windows_portal_server_block_size = 75
	api_server_ami = "ami-08ea1248edcfd23f2"
	api_server_instance_type = "t3.xlarge"
	api_server_root_block_size = 30
	workers_server_instance_type = "t3.xlarge"
	workers_server_ami = "ami-08ea1248edcfd23f2"
	workers_server_block_size = 30
	nms_server_ami = "ami-09c6b95cd647a61eb"
	nms_server_instance_type = "t3.large"
	servers_per_function = 1
	bootstrap_storage = true
	efs_id = module.storage.efs_id
	cluster_name = module.constants_cluster.cluster_shortname
	cluster_env = local.cluster_environment
	providers = {
		aws.dns = aws.dns
	}
}

module nms_workers {
	source = "../../../../../modules/aws/static-servers/modules/static-server"
	ami = "ami-01ff36b3398412875"
	cluster_env = local.cluster_environment
	cluster_name = local.cluster_shortname
	instance_type = "c5.2xlarge"
	key_name = "nms-services"
	patch_group = "ubuntu"
	server_name = "nms-workers"
	servers_per_function = 1
	security_group_ids = [module.networking.nms_security_group_id]
	subnet_ids = module.networking.nms_subnet_ids
	extra_tags = {"aex/purpose": "nms-workers"}
	providers = {
		aws.dns = aws.dns
	}
}

module elasticsearch {
	source = "../../../../../modules/aws/elasticsearch"
	subnet_ids = module.networking.db_subnet_ids
	vpc_id = module.vpc.vpc_id
	cluster_fqn = local.cluster_fqn
	dedicated_master_enabled = true
	dedicated_master_count = 3
	dedicated_master_type = "r5.large.elasticsearch"
	node_instance_count = 3
	node_instance_type = "r5.large.elasticsearch"
	ebs_options_volume_size = 250
	expose_to_vpn = true
	password = local.elastic_data_password
	saml_env = "prod"
	custom_domain = "elastic-data.${local.cluster_name}"
	providers = {
		aws.dns = aws.dns
	}
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
	k8s_namespaces = ["prod"]
	# TODO
	# kube_context = "aex-${replace(local.cluster_name, "_", "-")}-${replace(local.cluster_environment, "_", "-")}"
	# kube_context = "aex-vumatel-${replace(local.cluster_environment, "_", "-")}"
	kube_context = "vumatel-prod"
	node_capacity_type = "SPOT"
	app_nodes_quantity = 1
	app_node_instance_types = ["t3.medium"]
	devops_nodes_quantity = 1
	devops_node_instance_types = ["t3.large"]
	integration_nodes_quantity = 2
	integration_node_instance_types = ["t3.medium"]
	stable_devops_nodes_quantity = 1
	stable_devops_node_instance_types = ["t3.xlarge"]
	providers = {
		aws.secrets = aws.secrets
	}
}

module elasticache_parameter_group {
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

module elasticache_fno {
	source = "../../../../../modules/aws/elasticache/redis"
	node_type = "cache.m5.large"
	subnet_ids = module.networking.private_subnet_ids
	param_group = module.elasticache_parameter_group.name
	cluster_name = "${local.cluster_shortname}-fno"
	name = "${local.cluster_shortname}-fno"
	cluster_env = local.cluster_environment
	vpc_id = module.vpc.vpc_id
	vpc_cidr = local.vpc_cidr
	cluster_fqn = "${local.cluster_fqn}_fno"
	engine_version = "7.0"
	availability_zone = module.constants_cluster.aws_preferred_az
	providers = {
		aws.dns = aws.dns
	}
}

module elasticache_nms {
	source = "../../../../../modules/aws/elasticache/redis"
	node_type = "cache.m5.large"
	subnet_ids = module.networking.private_subnet_ids
	param_group = module.elasticache_parameter_group.name
	cluster_name = "${local.cluster_shortname}-nms"
	name = "${local.cluster_shortname}-nms"
	cluster_env = local.cluster_environment
	vpc_id = module.vpc.vpc_id
	vpc_cidr = local.vpc_cidr
	cluster_fqn = "${local.cluster_fqn}_nms"
	engine_version = "7.0"
	root_domain = module.constants.aex_i11l_systems_domain
	availability_zone = module.constants_cluster.aws_preferred_az
	providers = {
		aws.dns = aws.dns
	}
}

# Extra Routes Setup
module fno_vumatel_route {
	source = "../../../../../modules/aws/static-load-balancer/modules/extra_route"
	domain = "fno.vumatel.${module.constants.aex_legacy_domain}"
	root_domain = module.constants.aex_legacy_domain
	cluster_fqn = local.cluster_fqn
	providers = {
		aws.dns = aws.dns
	}
}

module events_vumatel_route {
	source = "../../../../../modules/aws/static-load-balancer/modules/extra_route"
	domain = "events.vumatel.${module.constants.aex_legacy_domain}"
	root_domain = module.constants.aex_legacy_domain
	cluster_fqn = local.cluster_fqn
	providers = {
		aws.dns = aws.dns
	}
}

module vumatel_events_route {
	source = "../../../../../modules/aws/static-load-balancer/modules/extra_route"
	domain = "vumatel.events.${module.constants.aex_legacy_domain}"
	root_domain = module.constants.aex_legacy_domain
	cluster_fqn = local.cluster_fqn
	providers = {
		aws.dns = aws.dns
	}
}

module static_load_balancer {
	source = "../../../../../modules/aws/static-load-balancer"
	cluster_fqn = local.cluster_fqn
	load_balancer_name = "svc"
	vpc_id = module.vpc.vpc_id
	api_server_ids = module.static_servers.api_server_ids
	nms_server_ids = module.static_servers.nms_server_ids
	subnets = module.networking.public_subnet_ids
	default_certificate_arn = data.aws_acm_certificate.default.arn
	cluster_name = local.cluster_name
	domain_environment = local.domain_environment
	security_group_id = aws_security_group.public_load_balancers.id
	logs_bucket = module.logs.bucket
	extra_tags = {"terraform":"infrastructure"}
	error_actions = local.error_actions
	warning_actions = local.warning_actions
	extra_fno_external_domains = [
		"fno.vumatel.${module.constants.aex_legacy_domain}"
	]
	extra_events_external_domains = [
		"events.vumatel.${module.constants.aex_legacy_domain}",
		"vumatel.events.${module.constants.aex_legacy_domain}"
	]
	providers = {
		aws.dns = aws.dns
	}
}

module internal_vumatel_route {
	source = "../../../../../modules/aws/static-load-balancer/modules/extra_route"
	domain = "internal.vumatel.${module.constants.aex_legacy_domain}"
	root_domain = module.constants.aex_legacy_domain
	target_override = "vumatel-prod-ip-external-227e4944982fb68f.elb.af-south-1.amazonaws.com" # TODO: Use a data component to get the CNAME of the NLB we're using for static IPs
	cluster_fqn = local.cluster_fqn
	providers = {
		aws.dns = aws.dns
	}
}

module sp_vumatel_route {
	source = "../../../../../modules/aws/static-load-balancer/modules/extra_route"
	domain = "sp.vumatel.${module.constants.aex_legacy_domain}"
	root_domain = module.constants.aex_legacy_domain
	cluster_fqn = local.cluster_fqn
	providers = {
		aws.dns = aws.dns
	}
}

module dark_fibre_africa_route {
	source = "../../../../../modules/aws/static-load-balancer/modules/extra_route"
	domain = "darkfibreafrica.${module.constants.aex_legacy_domain}"
	root_domain = module.constants.aex_legacy_domain
	cluster_fqn = local.cluster_fqn
	providers = {
		aws.dns = aws.dns
	}
}

module portal_route {
	source = "../../../../../modules/aws/portal-route"
	vpc_id = module.vpc.vpc_id
	portal_server_ids = module.static_servers.portal_server_ids
	domain_environment = "prod"
	portal_name = "sp"
	cluster_name = local.cluster_name
	listener_arn = module.static_load_balancer.listener_443_arn
	lb_dns = module.static_load_balancer.load_balancer_dns
	lb_arn_suffix = module.static_load_balancer.load_balancer_arn_suffix
	external_root_domain = module.constants.aex_legacy_domain
	internal_root_domain = module.constants.aex_i11l_internal_api_domain
	error_actions = local.error_actions
	warning_actions = local.warning_actions
	# sp.vumatel.co.za is CNAME'd to portal.vumatel.aex.co.za
	domain_name = "portal.vumatel.${module.constants.aex_legacy_domain}"
	extra_domains = [
		"sp.${module.constants_cluster.vumatel_domain}",
		"sp.vumatel.${module.constants.aex_legacy_domain}",
		"internal.vumatel.${module.constants.aex_legacy_domain}",
		"darkfibreafrica.${module.constants.aex_legacy_domain}",
	]
	providers = {
		aws.dns = aws.dns
	}
}

module k8s_ingress {
	source = "../../../../../modules/aws/k8s-ingress"
	cluster_name = local.cluster_name
	k8s_namespace = "prod"
	shared_services = local.shared_services
	internal_services = local.internal_services
	external_services = local.external_services
	external_service_map = []

	internal_root_domain = module.constants.aex_i11l_internal_api_domain
	external_root_domain = module.constants.aex_i11l_systems_domain

	logs_bucket = module.logs.bucket
	vpc_id = module.vpc.vpc_id
	aws_profile = "vumatel-prod"
	providers = {
		aws.dns = aws.dns
	}
}

resource aws_security_group_rule nms_ping {
	security_group_id = module.networking.nms_security_group_id
	type = "ingress"
	description = "VPN Ping"
	from_port = 8
	to_port = 0
	protocol = "icmp"
	cidr_blocks = module.constants_cluster.nms_routes
}

data aws_route_table integration {
	for_each = toset(local.integration_subnets)
	subnet_id = each.value
	depends_on = [module.networking]
}

module nms_vpn_routes {
	source = "../../../modules/vpn-routes"
	for_each = toset(local.integration_subnets)
	route_table_id = data.aws_route_table.integration[each.value].id
	transit_gateway_id = module.transit_gateway.transit_gateway_id
}

# Internal DNS Zone
resource aws_route53_vpc_association_authorization internal {
	vpc_id  = module.vpc.vpc_id
	zone_id = data.aws_route53_zone.internal.id
	provider = aws.dns
}

resource aws_route53_zone_association internal {
	vpc_id  = aws_route53_vpc_association_authorization.internal.vpc_id
	zone_id = aws_route53_vpc_association_authorization.internal.zone_id
}

module aws_cloudtrail {
 source = "../../../../../modules/aws/cloudtrail"
 cluster_name = local.cluster_name
 org_prefix = "vumatel"
}

module aws_thumbtribe {
	source = "../../../../../modules/aws/thumbtribe"
	env = local.cluster_environment
	org_prefix = "vumatel"
  
}
