# Server
module genie_acs {
  source = "../../aws/static-servers/modules/static-server"

  subnet_ids = var.subnets
  servers_per_function = 1
  server_name = "genie-acs"
  ami = var.ami_id
  patch_group = "ubuntu"
  cluster_env = var.cluster_env
  cluster_name = var.cluster_name
  key_name = "${var.key_prefix}static-services"
  instance_type = var.instance_type
  security_group_ids = [resource.aws_security_group.genie_acs_sg.id]
  extra_tags = {
    "aex/purpose" = "genie_acs"
  }

  providers = {
    aws.dns = aws.dns
  }
}

resource aws_eip acs {
  vpc = true
  instance = module.genie_acs.instance_ids[0]
  tags = {
    Name = "genie_acs_ip"
  }
}

resource aws_route53_record dns {
  zone_id = data.aws_route53_zone.lookup.id
  provider = aws.dns
  name = "acs.vumatel.${module.constants.aex_i11l_systems_domain}"
  type = "A"
  ttl = "300"
  records = [aws_eip.acs.public_ip]
}


# Routes
module genie_acs_https_route {
  source = "../../aws/static-load-balancer/modules/route"
  listener_arn = data.aws_lb_listener.https.arn
  domain = "genieacs.vumatel.${module.constants.aex_i11l_systems_domain}"
  lb_dns = data.aws_lb.lookup.dns_name
  lb_arn_suffix = data.aws_lb.lookup.arn_suffix
  root_domain = module.constants.aex_i11l_systems_domain
  target_port = 3000
  targets = module.genie_acs.instance_ids
  vpc_id = var.vpc_id
  target_protocol = "HTTP"
  health_check_protocol = "HTTP"
  target_group_name = "genie-acs-https"
  error_actions = [] #local.error_actions
  warning_actions = [] #local.warning_actions
  response_time_threshold = 1
  providers = {
    aws.dns = aws.dns
  }
}

module genie_acs_http_route {
  source = "../../aws/static-load-balancer/modules/route"
  listener_arn = data.aws_lb_listener.http.arn
  domain = "acs.vumatel.${module.constants.aex_i11l_systems_domain}"
  encrypted = false
  can_add_dns = false
  extra_domains = []
  lb_dns = data.aws_lb.lookup.dns_name
  lb_arn_suffix = data.aws_lb.lookup.arn_suffix
  root_domain = module.constants.aex_i11l_systems_domain
  target_port = 80
  targets = module.genie_acs.instance_ids
  vpc_id = var.vpc_id
  target_protocol = "HTTP"
  health_check_protocol = "HTTP"
  target_group_name = "genie-acs-http"
  error_actions = [] #local.error_actions
  warning_actions = [] #local.warning_actions
  response_time_threshold = 1
  providers = {
    aws.dns = aws.dns
  }
}

# Security Groups and Rules
resource aws_security_group genie_acs_sg {
  vpc_id = var.vpc_id

  name = "${var.cluster_fqn}_genie_acs_sg"
  description = "${var.cluster_fqn}_genie_acs_sg"

  tags = {
    Name = "${var.cluster_fqn}_genie_acs_sg"
    "aex/service" = true
    "aex/operations" = true
    "aex/vpn/pingable" = true
    "aex/operations/pingable" = true
    "aex/operations/prtg" = true
    "aex/vpn/ssh" = true
    "aex/operations/ssh" = true
  }
}

module ingress_vpc {
  source = "../../aws/networking/modules/ingress-vpc"
  security_group_id = resource.aws_security_group.genie_acs_sg.id
  vpc_cidr = data.aws_vpc.vpc.cidr_block
}

resource aws_security_group_rule global_cwmp {
  type = "ingress"
  from_port = local.cwmp_port
  to_port = local.cwmp_port
  protocol = "tcp"
  description = "GenieACS CWMP (Eveywhere)"
  cidr_blocks = ["0.0.0.0/0"] # Can potentially limit this to IPs we know...
  security_group_id = resource.aws_security_group.genie_acs_sg.id
}

module egress_all {
  source = "../../aws/networking/modules/egress-all"
  security_group_id = resource.aws_security_group.genie_acs_sg.id
}

# Storage
resource aws_efs_file_system efs_file_system {
  creation_token = "${var.cluster_fqn}_genie_acs_efs"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = "true"

  tags = {
    Name = "${var.cluster_fqn}_genie_acs_efs"
  }
}

resource aws_efs_mount_target efs_mount_target {
  for_each = var.subnets
  file_system_id = aws_efs_file_system.efs_file_system.id
  security_groups = [resource.aws_security_group.genie_acs_sg.id]
  subnet_id = each.value
}
