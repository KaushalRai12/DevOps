variable "iam_username" {
  type        = string
  description = "Name of the IAM user to be created"
}

variable "generate_access_key" {
  type        = bool
  description = "Whether to generate access keys for cli/api access"
}

variable "tags" {
  type        = map(any)
  description = "Standard set of tags to be attached to this modules resources"
}