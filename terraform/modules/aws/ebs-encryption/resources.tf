data aws_kms_key ebs {
  key_id = var.key_id
}

resource aws_ebs_default_kms_key default {
  key_arn = data.aws_kms_key.ebs.arn
}

resource aws_ebs_encryption_by_default default {
  enabled = var.enabled
}