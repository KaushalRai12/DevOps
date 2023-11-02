// ====================== Cluster Security group
resource aws_security_group cluster_security_group {
	vpc_id = var.vpc_id

	name = "${var.cluster_fqn}_eks_cluster_security_group"
	description = "Security group for the EKS cluster"

	tags = {
		Name = "${var.cluster_fqn}_eks_cluster_security_group",
		"kubernetes.io/cluster/${var.cluster_fqn}" = "owned"
	}
}

module egress_eks_all {
	source = "../networking/modules/egress-all"
	security_group_id = aws_security_group.cluster_security_group.id
}

module ingress_eks_vpc {
	source = "../networking/modules/ingress-vpc"
	security_group_id = aws_security_group.cluster_security_group.id
	vpc_cidr = var.vpc_cidr
}

resource aws_security_group_rule ingress_eks_self {
	type = "ingress"
	description = "self reference"
	from_port = 0
	to_port = 0
	protocol = -1
	self = true
	security_group_id = aws_security_group.cluster_security_group.id
}

resource aws_security_group_rule ingress_eks_kubectl_logs {
	type = "ingress"
	description = "kubectl logs from anywhere - MUST BE RESTRICTED TO VPN"
	from_port = 10250
	to_port = 10250
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
	security_group_id = aws_security_group.cluster_security_group.id
}

// ========================== EKS Cluster Role
resource aws_iam_role eks_role {
	name = "eks-cluster-${var.cluster_fqn}"
	assume_role_policy = file("${path.module}/templates/cluster-role-policy.json")
}

resource aws_iam_role_policy_attachment eks_policy {
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
	role = aws_iam_role.eks_role.name
}

// =========================== Cloudwatch logs
resource aws_cloudwatch_log_group eks_logs {
	name = "/aws/eks/${var.cluster_fqn}/cluster"
	retention_in_days = 7
}

// ============== EKS Cluster
resource aws_eks_cluster eks {
	enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
	name = var.cluster_fqn
	role_arn = aws_iam_role.eks_role.arn
	version = var.eks_version


	vpc_config {
		security_group_ids = [aws_security_group.cluster_security_group.id]
		subnet_ids = setunion(var.public_subnets, var.node_subnet_ids, var.integration_node_subnet_ids)
	}

	depends_on = [aws_cloudwatch_log_group.eks_logs]
}

// ================== OpenID Connector
data tls_certificate eks {
	url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

resource aws_iam_openid_connect_provider eks {
	client_id_list = ["sts.amazonaws.com"]
	thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
	url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

// =============== AWS CNI Role
data template_file cni_role_policy {
	template = file("${path.module}/templates/cni-role-policy.json.tpl")

	vars = {
		cluster_arn = aws_iam_openid_connect_provider.eks.arn
		cluster_url = trimprefix(aws_iam_openid_connect_provider.eks.url, "https://")
	}
}

resource aws_iam_role eks_cni {
	assume_role_policy = data.template_file.cni_role_policy.rendered
	name = "AmazonEKSCNIRole_${var.cluster_fqn}"
}

resource aws_iam_role_policy_attachment eks_cni_policy {
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
	role = aws_iam_role.eks_cni.name
}

// ==============  k8s Add ons
module cni_addon {
	source = "./modules/aws-cni"
	role_arn = aws_iam_role.eks_cni.arn
	kube_context = var.kube_context
	depends_on = [aws_eks_cluster.eks, null_resource.register_cluster]
}

resource aws_eks_addon aex-platform-eks-kube {
	cluster_name = var.cluster_fqn
	addon_name = "kube-proxy"
	depends_on = [aws_eks_cluster.eks]
}

// Node instance role
resource aws_iam_role node_instance {
	name = "aex-eks-node-instance-${replace(var.cluster_fqn, "_", "-")}"
	assume_role_policy = file("${path.module}/templates/node-instance-role-policy.json")
}

resource aws_iam_role_policy_attachment node_instance_AmazonEKSWorkerNodePolicy {
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
	role = aws_iam_role.node_instance.name
}

resource aws_iam_role_policy_attachment node_instance_AmazonEC2ContainerRegistryReadOnly {
	policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
	role = aws_iam_role.node_instance.name
}

resource aws_iam_role_policy_attachment node_instance_AmazonEKS_CNI_Policy {
	policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
	role = aws_iam_role.node_instance.name
}

resource aws_iam_role_policy_attachment node_instance_CloudWatch_Agent_Policy {
	policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
	role = aws_iam_role.node_instance.name
}

data aws_iam_policy eks_node_instance {
	name = module.constants.eks_node_instance_policy
}

resource aws_iam_role_policy_attachment node_instance {
	policy_arn = data.aws_iam_policy.eks_node_instance.arn
	role = aws_iam_role.node_instance.name
}

locals {
	autoscaler_tags = {
		"k8s.io/cluster-autoscaler/${aws_eks_cluster.eks.name}" : "owned"
		"k8s.io/cluster-autoscaler/enabled" : "true"
	}
}

//================== Application Nodes
resource aws_eks_node_group app_node_group {
	cluster_name = aws_eks_cluster.eks.name
	node_group_name = "app-nodes"
	node_role_arn = aws_iam_role.node_instance.arn
	subnet_ids = slice(var.node_subnet_ids, 0, min(max(var.app_nodes_quantity, 1), 2))
	instance_types = var.app_node_instance_types
	capacity_type = local.app_nodes_capacity_type

	labels = {
		"aex/app" : "true"
	}

	scaling_config {
		desired_size = var.app_nodes_quantity
		max_size = max(2, var.app_nodes_quantity + 2)
		min_size = max(0, var.app_nodes_quantity)
	}

	remote_access {
		ec2_ssh_key = "${local.key_prefix}eks"
		source_security_group_ids = [aws_security_group.cluster_security_group.id]
	}

	tags = merge({
		Name : "application-nodes"
	}, contains(var.auto_scale_groups, "app") ? merge(local.autoscaler_tags, {
		"k8s.io/cluster-autoscaler/node-template/label/aex/app" : "true"
	}) : {})
}

resource aws_eks_node_group stable_app_node_group {
	cluster_name = aws_eks_cluster.eks.name
	node_group_name = "stable-app-nodes"
	node_role_arn = aws_iam_role.node_instance.arn
	subnet_ids = slice(var.node_subnet_ids, 0, min(max(var.stable_app_nodes_quantity, 1), 2))
	instance_types = var.stable_app_node_instance_types
	capacity_type = "ON_DEMAND"

	labels = {
		"aex/app" : "true"
		"aex/stable" : "true"
	}

	scaling_config {
		desired_size = var.stable_app_nodes_quantity
		max_size = max(3, var.stable_app_nodes_quantity + 2)
		min_size = max(0, var.stable_app_nodes_quantity)
	}

	remote_access {
		ec2_ssh_key = "${local.key_prefix}eks"
		source_security_group_ids = [aws_security_group.cluster_security_group.id]
	}

	tags = merge({
		Name : "stable-app-nodes"
	}, contains(var.auto_scale_groups, "stable-app") ? merge(local.autoscaler_tags, {
		"k8s.io/cluster-autoscaler/node-template/label/aex/app" : "true"
		"k8s.io/cluster-autoscaler/node-template/label/aex/stable" : "true"
	}) : {})
}

resource aws_eks_node_group devops_node_group {
	cluster_name = aws_eks_cluster.eks.name
	node_group_name = "devops-nodes"
	node_role_arn = aws_iam_role.node_instance.arn
	subnet_ids = slice(var.node_subnet_ids, 0, min(max(var.devops_nodes_quantity, 1), 2))
	instance_types = var.devops_node_instance_types
	capacity_type = local.devops_nodes_capacity_type

	labels = {
		"aex/devops" : "true"
	}

	scaling_config {
		desired_size = var.devops_nodes_quantity
		max_size = max(3, var.devops_nodes_quantity + 2)
		min_size = max(0, var.devops_nodes_quantity)
	}

	remote_access {
		ec2_ssh_key = "${local.key_prefix}eks"
		source_security_group_ids = [aws_security_group.cluster_security_group.id]
	}

	tags = merge({
		Name : "devops-nodes"
	}, contains(var.auto_scale_groups, "devops") ? merge(local.autoscaler_tags, {
		"k8s.io/cluster-autoscaler/node-template/label/aex/devops" : "true"
	}) : {})
}

resource aws_eks_node_group stable_devops_node_group {
	cluster_name = aws_eks_cluster.eks.name
	node_group_name = "stable-devops-nodes"
	node_role_arn = aws_iam_role.node_instance.arn
	subnet_ids = slice(var.node_subnet_ids, 0, min(max(var.stable_devops_nodes_quantity, 1), 2))
	instance_types = var.stable_devops_node_instance_types
	capacity_type = "ON_DEMAND"

	labels = {
		"aex/devops" : "true"
		"aex/stable" : "true"
	}

	scaling_config {
		desired_size = var.stable_devops_nodes_quantity
		max_size = max(3, var.stable_devops_nodes_quantity + 2)
		min_size = max(0, var.stable_devops_nodes_quantity)
	}

	remote_access {
		ec2_ssh_key = "${local.key_prefix}eks"
		source_security_group_ids = [aws_security_group.cluster_security_group.id]
	}

	tags = merge({
		Name : "stable-devops-nodes"
	}, contains(var.auto_scale_groups, "stable-devops") ? merge(local.autoscaler_tags, {
		"k8s.io/cluster-autoscaler/node-template/label/aex/devops" : "true"
		"k8s.io/cluster-autoscaler/node-template/label/aex/stable" : "true"
	}) : {})
}

resource aws_eks_node_group integration_node_group {
	cluster_name = aws_eks_cluster.eks.name
	node_group_name = "integration-nodes"
	node_role_arn = aws_iam_role.node_instance.arn
	subnet_ids = slice(var.integration_node_subnet_ids, 0, min(max(var.integration_nodes_quantity, 1), 2))
	instance_types = var.integration_node_instance_types
	capacity_type = local.integration_nodes_capacity_type

	labels = {
		"aex/integration" : "true"
	}

	scaling_config {
		desired_size = var.integration_nodes_quantity
		max_size = max(2, var.integration_nodes_quantity + 2)
		min_size = min(1, var.integration_nodes_quantity)
	}

	remote_access {
		ec2_ssh_key = "${local.key_prefix}eks-integration"
		source_security_group_ids = [aws_security_group.cluster_security_group.id]
	}

	tags = merge({
		Name : "integration-nodes"
	}, contains(var.auto_scale_groups, "integration") ? merge(local.autoscaler_tags, {
		"k8s.io/cluster-autoscaler/node-template/label/aex/integration" : "true"
	}) : {})
}

resource aws_eks_node_group stable_integration_node_group {
	cluster_name = aws_eks_cluster.eks.name
	node_group_name = "stable-integration-nodes"
	node_role_arn = aws_iam_role.node_instance.arn
	subnet_ids = slice(var.node_subnet_ids, 0, min(max(var.stable_integration_nodes_quantity, 1), 2))
	instance_types = var.stable_integration_node_instance_types
	capacity_type = "ON_DEMAND"

	labels = {
		"aex/integration" : "true"
		"aex/stable" : "true"
	}

	scaling_config {
		desired_size = var.stable_integration_nodes_quantity
		max_size = max(3, var.stable_integration_nodes_quantity + 2)
		min_size = max(0, var.stable_integration_nodes_quantity)
	}

	remote_access {
		ec2_ssh_key = "${local.key_prefix}eks-integration"
		source_security_group_ids = [aws_security_group.cluster_security_group.id]
	}

	tags = merge({
		Name : "stable-integration-nodes"
	}, contains(var.auto_scale_groups, "stable-integration") ? merge(local.autoscaler_tags, {
		"k8s.io/cluster-autoscaler/node-template/label/aex/integration" : "true"
		"k8s.io/cluster-autoscaler/node-template/label/aex/stable" : "true"
	}) : {})
}

// ============= K8s manifests, config etc

# Register Cluster in your local .kube/config
resource null_resource register_cluster {

	provisioner local-exec {
		command = "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${var.cluster_fqn} --profile ${var.aws_profile} --alias ${var.kube_context}"
	}

	depends_on = [aws_eks_cluster.eks]
}

resource kubernetes_namespace devops {
	metadata {
		name = "aex-devops"
	}
	depends_on = [null_resource.register_cluster]
}

resource kubernetes_namespace others {
	for_each = toset(var.k8s_namespaces)
	metadata {
		name = "aex-${each.value}"
	}
	depends_on = [null_resource.register_cluster]
}

resource kubernetes_secret docker_registry_secrets {
	for_each = toset(concat(var.k8s_namespaces, ["devops"]))
	metadata {
		name = "gitlab-docker-registry"
		namespace = "aex-${each.value}"
	}

	type = "kubernetes.io/dockerconfigjson"

	data = {
		".dockerconfigjson" = jsonencode({
			auths = {
				"${var.gitlab_address}:4567" = {
					"username" = "service"
					"password" = local.gitlab_registry_password
					"email"    = var.devops_email
					"auth"     = base64encode("service:${local.gitlab_registry_password}")
				}
			}
		})
	}
	depends_on = [kubernetes_namespace.devops, kubernetes_namespace.others]
}

module k8s_security {
	source = "./modules/security"
	kube_context = var.kube_context
	namespaces = toset(concat(var.k8s_namespaces, ["devops"]))
}

module load-balancer-controller {
	source = "./modules/load-balancer-controller"
	cluster_fqn = var.cluster_fqn
	openid_arn = aws_iam_openid_connect_provider.eks.arn
	openid_url = aws_iam_openid_connect_provider.eks.url
	depends_on = [null_resource.register_cluster]
}

module autoscaler {
	source = "./modules/cluster-autoscaler"
	cluster_arn = aws_iam_openid_connect_provider.eks.arn
	cluster_fqn = var.cluster_fqn
	cluster_url = trimprefix(aws_iam_openid_connect_provider.eks.url, "https://")
	cluster_name = aws_eks_cluster.eks.name
	depends_on = [aws_eks_cluster.eks]
}

module ebs_csi_driver {
	source = "./modules/ebs-csi"
	cluster_arn = aws_iam_openid_connect_provider.eks.arn
	cluster_fqn = var.cluster_fqn
	cluster_url = trimprefix(aws_iam_openid_connect_provider.eks.url, "https://")
	depends_on = [aws_eks_cluster.eks]
}

module postgres_ingress {
	source = "./modules/postgres-ingress"
	cluster_fqn = var.cluster_fqn
	vpc_id = var.vpc_id
	depends_on = [aws_eks_cluster.eks]
}
