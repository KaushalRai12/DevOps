resource "aws_iam_user" "iam_user" {
  name = var.iam_username

  tags = var.tags
}

resource "aws_iam_access_key" "access_key" {
  count = var.generate_access_key ? 1 : 0
  user  = aws_iam_user.iam_user.name
}
