# Extend for group & role attachements
resource "aws_iam_policy" "policy" {
  name        = var.policy_name
  description = var.policy_description
  policy      = var.policy

  tags = var.tags
}

resource "aws_iam_user_policy_attachment" "policy_attachment" {
  user       = var.attached_user
  policy_arn = aws_iam_policy.policy.arn
}