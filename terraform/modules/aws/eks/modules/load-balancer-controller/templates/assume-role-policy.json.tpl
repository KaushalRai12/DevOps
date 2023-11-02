{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Federated": "${openid_arn}"
			},
			"Action": "sts:AssumeRoleWithWebIdentity",
			"Condition": {
				"StringEquals": {
					"${openid_url}:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
				}
			}
		}
	]
}
