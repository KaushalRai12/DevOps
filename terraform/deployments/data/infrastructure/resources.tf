module "quickbase_archive_storage" {
  source = "../../../modules/aws/s3"

  base_name         = "quickbase-archive"
  org_prefix        = "vumatel"
  env               = "production"
  enable_encryption = true
  enable_versioning = false

  public_acl_policy = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  tags = merge({
    environment = "production",
    project     = "vumatel-quickbase-archive"
    }
  )
}

# TODO clear IAM user and policy since it will only be once a off upload, won't be needed after archive
module "quickbase_archive_iam_user" {
  source = "../../../modules/aws/iam/users"

  iam_username        = "quickbase-archiver"
  generate_access_key = true

  tags = merge(
    {
      environment = "production",
      project     = "vumatel-quickbase-archive"
    }
  )
}

data "aws_iam_policy_document" "quickbase_archive_bucket_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    resources = ["${module.quickbase_archive_storage.s3_bucket_arn}/*"]
  }
}

module "quickbase_archive_iam_policy" {
  source = "../../../modules/aws/iam/policies"

  policy_name        = "quickbase-archiver-policy"
  policy_description = "Allow pushing to quickbase archive S3 bucket"
  policy             = data.aws_iam_policy_document.quickbase_archive_bucket_policy.json

  attached_user = module.quickbase_archive_iam_user.iam_user_username

  tags = merge({
    environment = "production",
    project     = "vumatel-quickbase-archive"
    }
  )
}

resource "aws_secretsmanager_secret" "quickbase_archive_secret" {
  name = "QuickbaseArchiveAccessKeys"
  
  tags = merge({
    environment = "production",
    project     = "vumatel-quickbase-archive"
    }
  )
}

resource "aws_secretsmanager_secret_version" "quickbase_archive_secret_version" {
  secret_id = aws_secretsmanager_secret.quickbase_archive_secret.id
  secret_string = jsonencode({
    access_key_id     = module.quickbase_archive_iam_user.iam_user_access_key_id,
    secret_access_key = module.quickbase_archive_iam_user.iam_user_access_key
  })
}