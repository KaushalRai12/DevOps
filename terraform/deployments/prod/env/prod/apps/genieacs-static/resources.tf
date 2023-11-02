module genie_acs {
  source = "../../../../../../modules/apps/genieacs-static"
  domain_environment = local.domain_environment
  cluster_fqn = local.cluster_fqn
  cluster_env = local.cluster_environment
  cluster_name = local.cluster_shortname
  vpc_id = module.constants_env.vpc_id
  subnets = data.aws_subnets.public_subnets.ids
  load_balancer_arn = "arn:aws:elasticloadbalancing:af-south-1:774405590946:loadbalancer/app/vumatel-prod-svc/05dd66e5f127753e"

  ami_id = local.ami_id
  providers = {
    aws.dns = aws.dns
  }
}
