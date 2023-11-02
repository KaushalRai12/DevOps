variable "sso_group_policies" {
  type = map(object({
    group_id         = string
    inline_policy    = string
    managed_policies = list(string)
    accounts         = list(string)
    session_duration = string
  }))
  description = "Policy for a SCIM created group and which accounts it belongs to"
}