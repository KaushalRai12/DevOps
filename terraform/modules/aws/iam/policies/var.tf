variable "policy_name" {
  description = "Name of the policy to be created"
  type        = string
}

variable "policy_description" {
  description = "Short explenation of what the policy does"
  type        = string
}

variable "policy" {
  description = "JSON formatted policy to attach"
  type        = string
}

variable "attached_user" {
  description = "User to attach policy to"
  type        = string
}

variable "tags" {
  type        = map(any)
  description = "Standard set of tags to be attached to this modules resources"
}