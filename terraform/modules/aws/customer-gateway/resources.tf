resource aws_customer_gateway customer_gateway {
	bgp_asn = 65000
	ip_address = var.customer_gateway_ip
	type = "ipsec.1"

	tags = {
		Name = var.customer_gateway_target
	}

  lifecycle {
    create_before_destroy = true
  }
}

output customer_gateway_id {
	value = aws_customer_gateway.customer_gateway.id
}
