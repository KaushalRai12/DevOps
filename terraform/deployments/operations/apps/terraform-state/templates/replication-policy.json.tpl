{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Action": [
				"s3:GetReplicationConfiguration",
				"s3:ListBucket"
			],
			"Effect": "Allow",
			"Resource": "${source_bucket}"
		},
		{
			"Action": [
				"s3:GetObjectVersion",
				"s3:GetObjectVersionForReplication",
				"s3:GetObjectVersionAcl"
			],
			"Effect": "Allow",
			"Resource": "${source_bucket}/*"
		},
		{
			"Action": [
				"s3:ReplicateObject",
				"s3:ReplicateDelete"
			],
			"Effect": "Allow",
			"Resource": "${destination_bucket}/*"
		}
	]
}
