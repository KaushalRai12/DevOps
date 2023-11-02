variable "base_name" {
  description = "Base name of the bucket"
  type        = string
}

variable "org_prefix" {
  description = "Organisational prefix for your bucket"
  type        = string

  validation {
    condition     = var.org_prefix == "aex" || var.org_prefix == "vumaex" || var.org_prefix == "vumatel"
    error_message = "org_prefix must be one of aex/vumaex/vumatel"
  }
}

variable "env" {
  description = "The name of the environment"
  type        = string
}

variable "public_acl_policy" {
  description = "Public ACL policy for the bucket"
  type = object({
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
}

variable "tags" {
  type        = map(any)
  description = "Standard set of tags to be attached to this modules resources"
}

variable "enable_encryption" {
  type        = bool
  description = "Enables kms key encryption on the S3 bucket"
}

variable "enable_versioning" {
  type        = bool
  description = "Enables object versioning on the S3 bucket"
}