resource aws_acm_certificate cert {
  domain_name = var.domain
  certificate_authority_arn = var.ca_authority_arn

  tags = {
    purpose = "client-vpn"
    Name = var.name
  }

  lifecycle {
    create_before_destroy = true
  }
}

output certificate_arn {
  value = aws_acm_certificate.cert.arn
}
