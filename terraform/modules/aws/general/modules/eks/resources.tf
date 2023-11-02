module constants {
	source = "../constants"
}

resource aws_iam_policy autoscaler {
	name = module.constants.eks_autoscaler_policy
	policy = file("${path.module}/templates/cluster-auto-scaler-policy.json")
}

resource aws_iam_policy load_balancer_controller {
	name = module.constants.eks_lb_controller_policy
	description = "Allows AWS controller to manipulate AWS"
	policy = file("${path.module}/templates/lb-controller-policy.json")
}

resource aws_iam_policy ebs_csi_driver {
	name = module.constants.ebs_csi_driver_policy
	description = "Allows AWS EBS CSI Driver to manage EC2 volumes"
	policy = file("${path.module}/templates/ebs-csi-policy.json")
}
