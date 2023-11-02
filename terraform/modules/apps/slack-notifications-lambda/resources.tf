resource aws_iam_role default {
  name = var.function_name
  assume_role_policy  = data.aws_iam_policy_document.lambda_role.json
}

resource aws_iam_policy lambda_policy {
  name = "aex-${var.function_name}"
  path = "/"
  description  = "AWS IAM Policy for managing aws lambda role"
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource aws_iam_role_policy_attachment lambda {
  role = aws_iam_role.default.name
  policy_arn  = aws_iam_policy.lambda_policy.arn
}

resource aws_lambda_function slack_notifications {
  filename = local.archive_file_output_path
  function_name   = var.function_name
  role = aws_iam_role.default.arn
  handler = local.handler
  runtime = local.runtime
  depends_on = [
    aws_iam_role_policy_attachment.lambda,
    aws_cloudwatch_log_group.log_group,
  ]

  environment {
    variables = {
      slack_url = local.slack_url
    }
  }
}

resource aws_cloudwatch_log_group log_group {
  name = "aex-${var.function_name}"
  retention_in_days = 14
}

resource aws_sns_topic topic {
  name = "cloudwatch-alarms"
}

resource aws_sns_topic_subscription target {
  topic_arn = aws_sns_topic.topic.arn
  protocol = "lambda"
  endpoint = aws_lambda_function.slack_notifications.arn
}
