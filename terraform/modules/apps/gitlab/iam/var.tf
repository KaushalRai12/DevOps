variable aws_profile {
	type = string
}

output key {
	value = aws_iam_access_key.gitlab.id
}

output secret {
	value = aws_iam_access_key.gitlab.secret
}
