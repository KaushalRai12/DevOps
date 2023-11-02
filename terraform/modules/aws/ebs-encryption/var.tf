variable key_id {
  type = string
  default = "alias/aws/ebs"
  description = "KMS key for EBS encryption"
}

variable enabled {
  type = bool
  default = true
  description = "EBS encryption enabled"
}