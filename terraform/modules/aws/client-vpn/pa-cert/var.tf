variable ca_authority_arn {
  description = "The ARN of the certificate authority"
  type = string
}

variable domain {
  description = "The domain for the certificate"
  type = string
  default = "vumaex.net"
}

variable name {
  description = "A descriptive name for the certificate"
  type = string
}
