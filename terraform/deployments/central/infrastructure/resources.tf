locals {
  account_list = data.aws_organizations_organization.organisation.accounts[*]
  cluster_name = module.constants_cluster.cluster_name
}

module "terraformer" {
  source = "../../../modules/aws/general/modules/terraformers"
}

module "sso" {
  source = "../../../modules/aws/sso"
  providers = {
    aws = aws.identity
  }

  sso_group_policies = {
    VumAEX-devops = {
      group_id      = data.aws_identitystore_group.devops.id
      inline_policy = null
      managed_policies = [
        "arn:aws:iam::aws:policy/AdministratorAccess"
      ]
      accounts = [
        local.account_list[index(local.account_list.*.name, "vumatel-central")].id,
        local.account_list[index(local.account_list.*.name, "vumatel-operations")].id,
        local.account_list[index(local.account_list.*.name, "vumatel-preprod")].id,
        local.account_list[index(local.account_list.*.name, "vumatel-prod")].id,
        local.account_list[index(local.account_list.*.name, "vumatel-transit")].id,
        local.account_list[index(local.account_list.*.name, "vumatel-data")].id
      ]
      session_duration = "PT1H"
    },
    AEX-monitoring = {
      group_id      = data.aws_identitystore_group.aex_monitoring.id
      inline_policy = data.aws_iam_policy_document.aex_monitoring_policy.json
      managed_policies = []
      accounts = [
        local.account_list[index(local.account_list.*.name, "vumatel-prod")].id
      ]
      session_duration = "PT8H"
    },
    VumAEX-developers = {
      group_id      = data.aws_identitystore_group.developers.id
      inline_policy = null
      managed_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonSNSReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess",
        "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess"
      ]
      accounts = [
        local.account_list[index(local.account_list.*.name, "vumatel-operations")].id,
        local.account_list[index(local.account_list.*.name, "vumatel-preprod")].id,
        local.account_list[index(local.account_list.*.name, "vumatel-prod")].id
      ]
      session_duration = "PT1H"
    },
    VumAEX-dba = {
      group_id      = data.aws_identitystore_group.dbas.id
      inline_policy = null
      managed_policies = [
        "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
      ]
      accounts = [
        local.account_list[index(local.account_list.*.name, "vumatel-preprod")].id,
        local.account_list[index(local.account_list.*.name, "vumatel-prod")].id
      ]
      session_duration = "PT1H"
    },
    VumAEX-readonly = {
      group_id      = data.aws_identitystore_group.readonlys.id
      inline_policy = null
      managed_policies = []
      accounts = []
      session_duration = "PT1H"
    },
    VumAEX-datascience = {
      group_id      = data.aws_identitystore_group.datascience.id
      inline_policy = data.aws_iam_policy_document.dms_policy.json
      managed_policies = [
        "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonAthenaFullAccess",
        "arn:aws:iam::aws:policy/CloudWatchFullAccess",
        "arn:aws:iam::aws:policy/AmazonRDSReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonElastiCacheReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonSNSReadOnlyAccess",
        "arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess",
        "arn:aws:iam::aws:policy/AWSSSOReadOnly",
        "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
      ]
      accounts = [
        local.account_list[index(local.account_list.*.name, "vumatel-central")].id,
        local.account_list[index(local.account_list.*.name, "vumatel-operations")].id,
        local.account_list[index(local.account_list.*.name, "vumatel-preprod")].id,
        local.account_list[index(local.account_list.*.name, "vumatel-prod")].id,
        local.account_list[index(local.account_list.*.name, "vumatel-data")].id
      ]
      session_duration = "PT1H"
    }
  }
}

module aws_cloudtrail {
 source = "../../../modules/aws/cloudtrail"
 cluster_name = local.cluster_name
 org_prefix = "vumatel"
}
