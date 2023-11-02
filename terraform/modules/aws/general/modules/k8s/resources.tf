resource aws_iam_group k8s_users {
	name = "k8s-users"
}

resource aws_iam_user helm_deployer {
	name = "helm-deployer"
	tags = {
		groups: "system:masters"
	}
}

resource aws_iam_user k8s_developer {
	name = "k8s-developer"
	tags = {
		groups: "system:viewers"
	}
}

resource aws_iam_user k8s_power_user {
	name = "k8s-power-user"
	tags = {
		groups: "system:viewers"
	}
}
resource aws_iam_user_group_membership helm_deployer {
	user = aws_iam_user.helm_deployer.name
	groups = [aws_iam_group.k8s_users.name]
}

resource aws_iam_user_group_membership k8s_developer {
	user = aws_iam_user.k8s_developer.name
	groups = [aws_iam_group.k8s_users.name]
}