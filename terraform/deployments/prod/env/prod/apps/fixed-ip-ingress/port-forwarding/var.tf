module constants_env {
	source = "../../../modules/constants"
}

variable source_port {
	description = "The outside port on which the external connection terminates"
	type = number
}

variable destination_port {
	description = "The inside port on which the service will be listening"
	type = number
	default = null
}

variable protocol {
	description = "The protocol being forwarded"
	type = string
	default = "tcp"
}

variable name {
	description = "A machine readable name for the port forwarding"
	type = string
	default = null
}

variable description {
	description = "A human readable description for the port forwarding"
	type = string
}

variable cidr {
	description = "The network ranges in which the network traffic will be delivered"
	type = set(string)
}

variable security_group_id {
	description = "The security group to attach the firewall rules to"
	type = string
	default = null
}

variable target_type {
	description = "The type of target the load balancer will be forwarding to"
	type = string
	default = "instance"
}

variable target_ids {
	description = "The instance ids or the IP addresses of the port forwarding destination"
	type = set(string)
}

variable load_balancer_arn {
	description = "The load balancer this port forwarding is running on"
	type = string
}

variable health_check_port {
	description = "The port on which the health check should be done"
	type = number
}

variable health_check_protocol {
	description = "Protocol used for health checks"
	type = string
	default = "TCP"
}

variable extra_tags {
	type = map(string)
	description = "Tags to apply"
	default = {}
}
