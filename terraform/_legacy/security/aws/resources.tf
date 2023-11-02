resource "aws_iam_policy" "route_53_editor_policy" {
	name = "aex-route-53-editor"
	description = "Allows updating records on Route 53."

	policy = file("${path.module}/route-53-editor-policy.json")
}

resource "aws_iam_group" "route_53_editors" {
	name = "route-53-editors"
}

resource "aws_iam_group_policy_attachment" "route_53_editors" {
	group = aws_iam_group.route_53_editors.name
	policy_arn = aws_iam_policy.route_53_editor_policy.arn
}

resource "aws_iam_group_membership" "route_53_editors" {
	name = "route-53-editors-membership"
	group = aws_iam_group.route_53_editors.name

	users = [
		"jck"
	]
}
