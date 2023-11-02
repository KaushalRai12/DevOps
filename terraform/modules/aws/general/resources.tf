#Create SNS Topic and Email Subscription
resource aws_sns_topic topic {
	name = "notifications"
}

resource aws_sns_topic_subscription email-target {
	topic_arn = aws_sns_topic.topic.arn
	protocol = "email"
	endpoint = "jrgns@aex.co.za" # TODO: Get a devops email
}

module default_lb_certificate {
	source = "../certificate"
	domain_name = "*.${var.root_domain}"
	name = "default-lb-certificate"
	root_domain = var.root_domain
	providers = {
		aws.dns = aws.dns
	}
}

module security {
	source = "./modules/security"
}

module eks {
	source = "./modules/eks"
}
