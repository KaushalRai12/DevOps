resource aws_dx_connection vumatel_1 {
  name = "TECT1-Connection-1"
  bandwidth = "1Gbps"
  location = "TECT1"
  tags = {
    "Cross connect refs" = "SO134624"
    "directconnect:resiliency-bundle-id" = "e02fa067-6ec7-4b88-9f2c-f171c9e7d7f0"
    "directconnect:resiliency-level" = "development"
    "provider" = "Vumatel"    
  }
}

resource aws_dx_connection vumatel_2 {
  name = "TECT1-Connection-2"
  bandwidth = "1Gbps"
  location = "TECT1"
  tags = {
    "Cross connect refs" = "SO134625"
    "directconnect:resiliency-bundle-id" = "e02fa067-6ec7-4b88-9f2c-f171c9e7d7f0"
    "directconnect:resiliency-level" = "development"
    "provider" = "Vumatel"    
  }
}

resource aws_dx_gateway vumatel-1 {
  name = "vumatel-1"
  amazon_side_asn = "64848"
}

resource aws_dx_private_virtual_interface vumatel-private-1 {
  name = "vumatel-private-1"
  connection_id = "dxcon-fhdj3u6p"
  vlan = 129
  bgp_asn = 65448
  address_family = "ipv4"
  mtu = 9001
  amazon_address = "10.174.20.46/30"
  customer_address = "10.174.20.45/30"
  dx_gateway_id = resource.aws_dx_gateway.vumatel-1.id
}

resource aws_dx_private_virtual_interface vumatel-private-2 {
  name = "vumatel-private-2"
  connection_id = "dxcon-fg5h8r15"
  vlan = 158
  bgp_asn = 65448
  address_family = "ipv4"
  mtu = 9001
  amazon_address = "10.174.20.90/30"
  customer_address = "10.174.20.89/30"
  dx_gateway_id = resource.aws_dx_gateway.vumatel-1.id
}
