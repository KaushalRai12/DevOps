module prod_vpn {
  source = "../../../../../../modules/aws/client-vpn"
  subnet_ids = [data.aws_subnets.all.ids[0]]
  client_certs = [
  ]
  target_cidr_block = data.aws_vpc.vpc.cidr_block
}
