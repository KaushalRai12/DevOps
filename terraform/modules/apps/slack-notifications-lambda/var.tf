locals {
  handler = "slack-notifications.lambda_handler"
  runtime = "python3.9"
  archive_file_output_path = "${path.module}/templates/slack-notifications.zip"
  archive_file_source_dir = "${path.module}/templates"
  slack_url = jsondecode(data.aws_secretsmanager_secret_version.slack.secret_string)["notifications-webhook-url"]
}

variable function_name {
  type = string
  default = "slack-notifications"
}

data archive_file zip_code {
  type        = "zip"
  source_dir  = local.archive_file_source_dir
  output_path = local.archive_file_output_path
}


data aws_iam_policy_document lambda_policy {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]

    effect = "Allow"
  }
}

data aws_iam_policy_document lambda_role {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data aws_region current {}

data aws_caller_identity current {}

data aws_secretsmanager_secret_version slack {
  secret_id = "slack"
  provider = aws.secrets
}
