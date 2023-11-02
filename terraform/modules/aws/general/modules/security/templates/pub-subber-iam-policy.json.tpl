{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"sns:ConfirmSubscription",
				"sns:CreateTopic",
				"sns:GetTopicAttributes",
				"sns:ListSubscriptionsByTopic",
				"sns:ListTagsForResource",
				"sns:Publish",
				"sns:SetTopicAttributes",
				"sns:Subscribe",
				"sns:TagResource",
				"sns:UntagResource",
				"sqs:ChangeMessageVisibility",
				"sqs:ChangeMessageVisibilityBatch",
				"sqs:CreateQueue",
				"sqs:DeleteMessage",
				"sqs:DeleteMessageBatch",
				"sqs:GetQueueAttributes",
				"sqs:GetQueueUrl",
				"sqs:ListDeadLetterSourceQueues",
				"sqs:ListQueueTags",
				"sqs:PurgeQueue",
				"sqs:ReceiveMessage",
				"sqs:SendMessage",
				"sqs:SendMessageBatch",
				"sqs:SetQueueAttributes",
				"sqs:TagQueue",
				"sqs:UntagQueue"
			],
			"Resource": [
				"arn:aws:sns:${region}:${account_id}:*",
				"arn:aws:sqs:${region}:${account_id}:*"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"sns:CheckIfPhoneNumberIsOptedOut",
				"sns:CreatePlatformApplication",
				"sns:CreatePlatformEndpoint",
				"sns:CreateSMSSandboxPhoneNumber",
				"sns:GetEndpointAttributes",
				"sns:GetPlatformApplicationAttributes",
				"sns:GetSMSAttributes",
				"sns:GetSMSSandboxAccountStatus",
				"sns:GetSubscriptionAttributes",
				"sns:ListEndpointsByPlatformApplication",
				"sns:ListOriginationNumbers",
				"sns:ListPhoneNumbersOptedOut",
				"sns:ListPlatformApplications",
				"sns:ListSMSSandboxPhoneNumbers",
				"sns:ListSubscriptions",
				"sns:ListTopics",
				"sns:OptInPhoneNumber",
				"sns:SetEndpointAttributes",
				"sns:SetPlatformApplicationAttributes",
				"sns:SetSMSAttributes",
				"sns:SetSubscriptionAttributes",
				"sns:Unsubscribe",
				"sns:VerifySMSSandboxPhoneNumber",
				"sqs:ListQueues"
			],
			"Resource": "*"
		}
	]
}
