locals {
	eks_autoscaler_policy = "AmazonEKSClusterAutoscalerPolicy"
	eks_lb_controller_policy = "aws-load-balancer-controller-iam-policy"
	ebs_csi_driver_policy = "EbsCsiDriverPolicy"
}

output eks_autoscaler_policy {
	value = local.eks_autoscaler_policy
}

output eks_lb_controller_policy {
	value = local.eks_lb_controller_policy
}

output ebs_csi_driver_policy {
	value = local.ebs_csi_driver_policy
}
