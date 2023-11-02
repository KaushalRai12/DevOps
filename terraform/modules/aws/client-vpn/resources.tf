# module vpn_cname {
#   source = "../dns-cname/modules/unwrapped"
#   domain_name = var.domain
#   target = aws_ec2_client_vpn_endpoint.certificate_vpn.dns_name
#   root_domain = var.domain
#   providers = {
#     aws.dns = aws.dns
#   }
# }

module root_cert {
  source = "./pa-cert"
  ca_authority_arn = aws_acmpca_certificate_authority.vumaex_authority.arn
  domain = var.domain
  name = "Root Cert"
}

module server_cert {
  source = "./pa-cert"
  ca_authority_arn = aws_acmpca_certificate_authority.vumaex_authority.arn
  domain = var.domain
  name = "Server Cert"
}

module client_cert {
  source = "./pa-cert"
  for_each = toset(var.client_certs)
  ca_authority_arn = aws_acmpca_certificate_authority.vumaex_authority.arn  
  domain = var.domain
  name = each.key
}

resource aws_acmpca_certificate_authority vumaex_authority {
  tags = { "terraform": "apps/client-vpn" }
  type = "ROOT"

  certificate_authority_configuration {
    key_algorithm = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      common_name = var.domain
    }
  }

  permanent_deletion_time_in_days = 7
}

resource aws_cloudwatch_log_group log_group {
  name = "aex-vpn"
  retention_in_days = 14
}

resource aws_cloudwatch_log_stream log_stream {
  name = "certificate-vpn"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}

resource aws_ec2_client_vpn_endpoint certificate_vpn {
  split_tunnel = true
  description = "certificate-vpn"
  server_certificate_arn = module.server_cert.certificate_arn
  client_cidr_block = var.client_cidr_block
  dns_servers = var.dns_servers
  tags = { "terraform": "apps/client-vpn", "Name": "prod-vpn" }

  authentication_options {
    type = "certificate-authentication"
    root_certificate_chain_arn = module.root_cert.certificate_arn
  }

  connection_log_options {
    enabled = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.log_group.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.log_stream.name
  }
}

resource aws_ec2_client_vpn_authorization_rule all_users {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.certificate_vpn.id
  target_network_cidr = var.target_cidr_block
  authorize_all_groups = true
}

resource aws_ec2_client_vpn_network_association private_a {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.certificate_vpn.id
  for_each = toset(var.subnet_ids)
  subnet_id = each.key
}
