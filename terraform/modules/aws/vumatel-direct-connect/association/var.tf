variable gateway_id {
  type = string
  description = "The ID of the Direct Connect Gateway to asssociate to (transit)"
}

variable vpn_gateway_id {
  type = string
  description = "The ID of the Virtual Private Gateway to asssociate to (receiving)"
}

variable vpc_cidr {
  type = string
}

data aws_caller_identity current { }
