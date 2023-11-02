{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Federated": "${cluster_arn}"
			},
			"Action": "sts:AssumeRoleWithWebIdentity",
			"Condition": {
				"StringEquals": {
					"${cluster_url}:aud": "system:serviceaccount:kube-system:aws-node"
				}
			}
		}
	]
}
