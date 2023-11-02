{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"s3:GetAccessPoint",
				"s3:PutAccountPublicAccessBlock",
				"s3:GetAccountPublicAccessBlock",
				"s3:ListAllMyBuckets",
				"s3:ListAccessPoints",
				"s3:ListJobs",
				"s3:CreateJob"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": "s3:*",
			"Resource": [
				"${s3_bucket}",
				"arn:aws:s3::${account_id}:job/*",
				"arn:aws:s3::${account_id}:accesspoint/*",
				"${s3_bucket}/*"
			]
		}
	]
}
