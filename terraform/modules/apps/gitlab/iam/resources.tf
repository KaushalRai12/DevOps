resource aws_iam_user gitlab {
	name = "gitlab"
}

resource aws_iam_access_key gitlab {
	user = aws_iam_user.gitlab.name
}
