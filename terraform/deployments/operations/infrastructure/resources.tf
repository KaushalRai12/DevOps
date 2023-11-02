module logs {
	source = "../../../modules/aws/log-bucket"
	log_bucket_name = module.constants_cluster.logs_bucket
}

module general {
	source = "../../../modules/aws/general"
	root_domain = module.constants.aex_i11l_systems_domain
	providers = {
		aws.dns = aws
	}
}

module patch_management {
	source = "../../../modules/aws/patch-management"
	logs_bucket = module.logs.bucket
}

module ebs_encryption {
	source = "../../../modules/aws/ebs-encryption"
	enabled = true
}

resource aws_iam_service_linked_role es {
	aws_service_name = "es.amazonaws.com"
	description = "Allows Amazon ES to manage AWS resources for a domain on your behalf."
}

module vpc {
	source = "../../../modules/aws/vpc"
	cluster_fqn = local.cluster_fqn
	vpc_cidr = local.vpc_cidr
	logs_bucket_arn = module.logs.bucket_arn
}

module networking {
	source = "../../../modules/aws/networking"
	cluster_fqn = local.cluster_fqn
	vpc_cidr = local.vpc_cidr
	vpc_id = module.vpc.vpc_id
	integration_cidr = local.integration_cidr
	vpn_gateway_id = module.vpc.vpn_gateway_id
	shared_nat_gateway = true
}

module transit_gateway {
	source = "../../../modules/aws/transit-gateway/attached"
	cluster_fqn = local.cluster_fqn
	vpc_id = module.vpc.vpc_id
	vpc_cidr = local.vpc_cidr
	subnet_ids = module.networking.private_subnet_ids
	add_ops_route = false
	# extra_vpn_routes = module.constants_cluster.rosebank_nms_routes
	providers = {
		aws.transit = aws.transit
	}
}

module direct_connect_attachment {
	source = "../../../modules/aws/vumatel-direct-connect/association"
	vpc_cidr = local.vpc_cidr
	gateway_id = data.aws_dx_gateway.transit.id
	vpn_gateway_id = module.vpc.vpn_gateway_id
	providers = {
		aws.transit = aws.transit
	}
}

module s3_backups {
	source = "../../../modules/aws/backups"
	cluster_name = module.constants_cluster.cluster_name
	org_prefix = "vumatel"
}

module eks {
	source = "../../../modules/aws/eks"
	cluster_fqn = local.cluster_fqn
	aws_profile = module.constants_cluster.aws_profile
	node_subnet_ids = module.networking.eks_node_subnet_ids
	public_subnets = module.networking.public_subnet_ids
	integration_node_subnet_ids = module.networking.eks_integration_node_subnet_ids
	node_security_group_ids = [module.networking.eks_node_security_group_id]
	integration_node_security_group_ids = [module.networking.eks_integration_security_group_id]
	vpc_id = module.vpc.vpc_id
	vpc_cidr = local.vpc_cidr
	k8s_namespaces = []
	kube_context = local.k8s_context
	devops_node_instance_types = ["t3.large"]
	node_capacity_type = "SPOT"
	app_nodes_quantity = 0
	devops_nodes_quantity = 1
	stable_devops_nodes_quantity = 0
	integration_nodes_quantity = 0
	gitlab_secret_name = "gitlab"
	devops_email = module.constants.devops_email
	providers = {
		aws.secrets = aws
	}
}

resource aws_route53_zone internal {
	name = "vumaex.internal"

	vpc {
		vpc_id = module.vpc.vpc_id
	}

	# Prevent the deletion of associated VPCs after
	# the initial creation. See documentation on
	# aws_route53_zone_association for details
	lifecycle {
		ignore_changes = [vpc]
	}
}

resource aws_eks_node_group ci_node_group {
	cluster_name = module.eks.cluster_name
	node_group_name = "ci-nodes"
	node_role_arn = module.eks.node_role_arn
	subnet_ids = module.networking.eks_node_subnet_ids
	instance_types = ["c5.2xlarge", "c5a.2xlarge", "c5d.2xlarge"]
	capacity_type = "SPOT"
	// Have run out of space (in some circumstances) with the default 20G
	disk_size = 30

	labels = {
		"aex/ci" : "true"
	}

	scaling_config {
		desired_size = 0
		max_size = 6
		min_size = 0
	}

	remote_access {
		ec2_ssh_key = "eks"
		source_security_group_ids = [module.eks.cluster_security_group_id]
	}

	tags = {
		Name : "ci-nodes"
		"k8s.io/cluster-autoscaler/${module.eks.cluster_name}" : "owned"
		"k8s.io/cluster-autoscaler/enabled" : "true"
		"k8s.io/cluster-autoscaler/node-template/label/aex/ci" : "true"
	}

	lifecycle {
//		ignore_changes = [scaling_config.0.desired_size]
	}
}

data aws_route53_zone dns_blue {
	name = module.constants.aex_i11l_infrastructure_domain
}

data aws_route53_zone dns_co_za {
	name = module.constants.aex_za_client_facing_domain
}

data aws_route53_zone dns_net {
	name = module.constants.aex_i11l_systems_domain
}

data aws_iam_policy_document certbot {
	statement {
		effect = "Allow"
		actions = [
			"route53:ListHostedZones",
			"route53:GetChange"
		]
		resources = ["*"]
	}

	statement {
		effect = "Allow"
		actions = ["route53:ChangeResourceRecordSets"]
		resources = [
			"arn:aws:route53:::hostedzone/${data.aws_route53_zone.dns_net.id}",
			"arn:aws:route53:::hostedzone/${data.aws_route53_zone.dns_blue.id}",
			"arn:aws:route53:::hostedzone/${data.aws_route53_zone.dns_co_za.id}",
		]
	}
}

resource aws_iam_policy certbot {
	name = "vumatel-certbot"
	description = "For certbot DNS challenges"
	policy = data.aws_iam_policy_document.certbot.json
}

resource aws_iam_user certbot {
	name = "certbot"
}

resource aws_iam_user_policy_attachment certbot {
	policy_arn = aws_iam_policy.certbot.arn
	user = aws_iam_user.certbot.name
}

module aws_cloudtrail {
 source = "../../../modules/aws/cloudtrail"
 cluster_name = local.cluster_name
 org_prefix = "vumatel"
}
