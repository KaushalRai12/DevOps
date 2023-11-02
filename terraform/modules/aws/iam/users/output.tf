output "iam_user_username" {
  value = aws_iam_user.iam_user.name
}

output "iam_user_access_key" {
  value     = aws_iam_access_key.access_key[0].secret
  sensitive = true
}

output "iam_user_access_key_id" {
  value     = aws_iam_access_key.access_key[0].id
  sensitive = true
}