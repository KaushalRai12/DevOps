
# IAM Identity Center users/groups will be synced from Azure AD into AWS via SCIM. Data block per user/group is required to assign permission sets and access per account

data "aws_ssoadmin_instances" "identity_center" {
  provider = aws.identity
}

data "aws_organizations_organization" "organisation" {}

data "aws_identitystore_group" "devops" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.identity_center.identity_store_ids)[0]

  provider = aws.identity
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "VumAEX-devops"
    }
  }
}

data "aws_identitystore_group" "developers" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.identity_center.identity_store_ids)[0]

  provider = aws.identity
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "VumAEX-developers"
    }
  }
}

data "aws_identitystore_group" "dbas" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.identity_center.identity_store_ids)[0]

  provider = aws.identity
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "VumAEX-dba"
    }
  }
}

data "aws_identitystore_group" "readonlys" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.identity_center.identity_store_ids)[0]

  provider = aws.identity
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "VumAEX-readonly"
    }
  }
}

data "aws_identitystore_group" "datascience" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.identity_center.identity_store_ids)[0]

  provider = aws.identity
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "VumAEX-datascience"
    }
  }
}

data "aws_identitystore_group" "aex_monitoring" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.identity_center.identity_store_ids)[0]

  provider = aws.identity
  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "AEX-monitoring"
    }
  }
}

data "aws_iam_policy_document" "aex_monitoring_policy" {
  statement {
    sid = "AllowCloudWatchRead"

    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*",
    ]

    effect = "Allow"
    resources = ["*"]		
  }
}

data "aws_iam_policy_document" "dms_policy" {
  statement {
    sid = "AllowDMSPowerUser"

    actions = [
      "dms:*",
    ]

    effect = "Allow"
    resources = ["*"]		
  }
}