resource aws_iam_group terraformers {
	name = "terraformers"
}

resource aws_iam_group_policy_attachment terraformers {
	group = aws_iam_group.terraformers.name
	policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource aws_iam_user terraformer {
	name = "terraformer"
	tags = {
		groups: "system:masters"
	}
}

resource aws_iam_user_group_membership terraformer {
	user = aws_iam_user.terraformer.name
	groups = [aws_iam_group.terraformers.name]
}
