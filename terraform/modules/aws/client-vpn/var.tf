locals {
	env = "prod"
}

variable domain {
	description = "The domain for the Client VPN"
	type = string
	default = "vumaex.net"
}

variable client_cidr_block {
  description = "The CIDR in which the client will be placed"
  type = string
  default = "10.184.252.0/22"
}

variable target_cidr_block {
  description = "The CIDR to which the client will be connecting"
  type = string
}

variable dns_servers {
  description = "DNS servers provided to the VPN client"
  type = list(string)
  default = ["1.1.1.1", "8.8.8.8"]
}

variable client_certs {
  description = "Identifiers for clients that will need certificates"
  type = list(string)
}

variable subnet_ids {
  description = "Subnets to asssociate with the VPN"
  type = list(string)
}
