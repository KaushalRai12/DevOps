module iam {
	source = "../../../../modules/apps/gitlab/iam"
	aws_profile = module.constants_cluster.aws_profile
}

module cache_bucket {
	source = "../../../../modules/apps/gitlab/cache-bucket"
	bucket_name = "vumatel-gitlab-cache"
	depends_on = [module.iam]
}

module runner {
	source = "../../../../modules/apps/gitlab/runner"
	k8s_runner_tag = "aws-k8s"
	cache_bucket_name = module.cache_bucket.bucket_name
	cache_key = module.iam.key
	cache_secret = module.iam.secret
	cpu_request = "3500m"
	memory_request = "6Gi"
	registration_token = local.registration_token
	gitlab_url = local.domain_name
	requires_stable_nodes = false
}

resource aws_security_group gitlab {
	vpc_id = module.constants_cluster.vpc_id

	name = "gitlab-server"
	description = "Gitlab Server"

	tags = {
		Name = "gitlab-server"
	}
}

module gitlab_server {
	source = "../../../../modules/aws/static-servers/modules/static-server"
	// Based on gitlab recommended requirements: https://docs.gitlab.com/ee/install/requirements.html#cpu
	instance_type = "c5.xlarge"
	key_name = "operations"
	subnet_ids = data.aws_subnets.public.ids
	server_name = "gitlab"
	ami = "ami-06ada9dac4aff09c9"
	security_group_ids = [data.aws_security_group.services.id, aws_security_group.gitlab.id]
	servers_per_function = 1
	root_block_size = 100
	requires_elastic_ip = true
	cluster_name = null
	cluster_env = null
	patch_group = "ubuntu"
	root_domain = module.constants.aex_i11l_infrastructure_domain
	providers = {
		aws.dns = aws.operations
	}
}

module server_ingress {
	source = "../../../../modules/aws/networking/modules/ingress-public"
	ports = [443, 22, 4567]
	security_group_id = aws_security_group.gitlab.id
	description = "Public ingress"
}

module server_ingress_vpn {
	source = "../../../../modules/aws/networking/modules/ingress-vpn"
	ports = [22]
	security_group_id = aws_security_group.gitlab.id
	description = "VPN ingress"
}

resource aws_route53_record a_record {
	zone_id = data.aws_route53_zone.zone.zone_id
	name = "gitlab"
	type = "A"
	ttl = 600
	records = module.gitlab_server.public_ips
}

data aws_iam_policy_document registry {
	statement {
		effect = "Allow"
		actions = [
			"s3:ListBucket",
			"s3:GetBucketLocation",
			"s3:ListBucketMultipartUploads",
		]
		resources = [aws_s3_bucket.registry.arn]
	}

	statement {
		effect = "Allow"
		actions = [
			"s3:PutObject",
			"s3:GetObject",
			"s3:DeleteObject",
			"s3:ListMultipartUploadParts",
			"s3:AbortMultipartUpload"
		]
		resources = ["${aws_s3_bucket.registry.arn}/*"]
	}
}

resource aws_s3_bucket registry {
	bucket = "vumatel-gitlab-container-registry"
}

resource aws_s3_bucket_acl registry {
	bucket = aws_s3_bucket.registry.id
	acl = "private"
}

resource aws_s3_bucket_public_access_block bucket_access_block {
	bucket = aws_s3_bucket.registry.id
	block_public_acls = true
	block_public_policy = true
	ignore_public_acls = true
	restrict_public_buckets = true
}

resource aws_iam_policy bucket_policy {
	name = "vumatel-gitlab-container-registry"
	policy = data.aws_iam_policy_document.registry.json
}

resource aws_iam_user_policy_attachment bucket_user_policy {
	user = "gitlab"
	policy_arn = aws_iam_policy.bucket_policy.arn
}

