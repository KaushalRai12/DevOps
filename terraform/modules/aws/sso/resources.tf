locals {
  account_assignments = distinct(flatten([
    for group_key, group in var.sso_group_policies : [
      for account_id in group.accounts : {
        permission_set_name = group_key
        sso_group_id        = group.group_id
        account_id          = account_id
        session_duration    = group.session_duration
      }
    ]
  ]))

  mananged_policies = distinct(flatten([
    for group_key, group in var.sso_group_policies : [
      for policy_arn in group.managed_policies : {
        permission_set_name = group_key
        policy_arn          = policy_arn
      }
    ]
  ]))
}

resource "aws_ssoadmin_permission_set" "permission_set" {
  for_each = var.sso_group_policies

  name             = each.key
  instance_arn     = tolist(data.aws_ssoadmin_instances.identity_center.arns)[0]
  session_duration = each.value.session_duration
}

resource "aws_ssoadmin_permission_set_inline_policy" "inline_policy" {
  for_each = { for k, v in var.sso_group_policies : k => v if v.inline_policy != null }

  inline_policy      = each.value.inline_policy
  instance_arn       = aws_ssoadmin_permission_set.permission_set[each.key].instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.key].arn
}

resource "aws_ssoadmin_managed_policy_attachment" "managed_policy" {
  for_each = {
    for policy in local.mananged_policies :
    "${policy.permission_set_name}.${policy.policy_arn}" => policy
  }

  managed_policy_arn = each.value.policy_arn
  instance_arn       = aws_ssoadmin_permission_set.permission_set[each.value.permission_set_name].instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.value.permission_set_name].arn
}

resource "aws_ssoadmin_account_assignment" "scim_group_account_assignment" {
  for_each = {
    for assignment in local.account_assignments :
    "${assignment.permission_set_name}.${assignment.account_id}" => assignment
  }

  instance_arn       = aws_ssoadmin_permission_set.permission_set[each.value.permission_set_name].instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.permission_set[each.value.permission_set_name].arn

  principal_id   = each.value.sso_group_id
  principal_type = "GROUP"

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"
}
