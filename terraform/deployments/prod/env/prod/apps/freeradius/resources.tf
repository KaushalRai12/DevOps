locals {
  identifier = "radius-main"
  multi_az = true
  replicated = false
  name = "freeradius"
  engine = "postgres"
  engine_version = "13.7"
  family = "postgres13"
  major_engine_version = "13"
  instance_class = "db.m5.large"
  domain_suffix = "vumatel.vumaex.net"
  allocated_storage = 50
  max_allocated_storage = 1000
  maintenance_window = "Sun:00:00-Sun:01:00"
  parameters = [
    {
      name = "autovacuum"
      value = 1
    },
    {
      name = "rds.logical_replication"
      value = 1
      apply_method = "pending-reboot"
    },
    {
      name = "shared_preload_libraries",
      value = "pg_stat_statements,pg_cron,pglogical",
      apply_method = "pending-reboot"
    }
  ]
}

module freeradius {
  source = "../../../../../../modules/apps/freeradius"
  domain_environment = local.domain_environment
  cluster_fqn = local.cluster_fqn
  cluster_env = local.cluster_environment
  cluster_name = local.cluster_shortname
  vpc_id = module.constants_env.vpc_id
  subnets = data.aws_subnets.nms_subnets.ids
  load_balancer_arn = data.aws_lb.internal.arn
  ami_id = local.ami_id
  providers = {
    aws.dns = aws.dns
  }
}

module radius_historic_db {
  source = "../../../../../../modules/aws/storage/postgres-rds/"
  cluster_env = local.cluster_environment
  cluster_name = local.cluster_shortname
  db_identifier = "radius-historic"
  db_security_group_id = data.aws_security_group.db_private_security_group.id
  db_subnet_group_name = "${local.cluster_fqn}_db_subnet_group"
  engine_version = "13.3"
  instance_class = "db.t3.medium"
  # TODO: Find a better way to centralize this
  parameter_group_name = "radius-main-master-20220810144823595800000001"
  password = local.radius_sql_password
  allocated_storage = 50
  max_allocated_storage = 300
  expose_to_vpn = true
  providers = {
    aws.dns = aws.dns
  }
}

# Master DB
module radius_master_db {
  # git clone https://github.com/terraform-aws-modules/terraform-aws-rds.git
  source = "./terraform-aws-rds"

  identifier = "${local.identifier}-master"

  engine = local.engine
  engine_version = local.engine_version
  family = local.family
  major_engine_version = local.major_engine_version
  instance_class = local.instance_class
  parameters = local.parameters

  allocated_storage = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage

  db_name  = local.name
  username = "postgres"
  # port     = local.port

  multi_az = local.multi_az
  db_subnet_group_name = "${local.cluster_fqn}_db_subnet_group"
  vpc_security_group_ids = [data.aws_security_group.db_private_security_group.id]

  maintenance_window = local.maintenance_window
  backup_window = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  performance_insights_enabled = true
  performance_insights_retention_period = 7
  monitoring_role_arn = data.aws_iam_role.monitoring.arn
  monitoring_interval = 60

  # Backups are required in order to create a replica
  backup_retention_period = 1
  skip_final_snapshot = true
  deletion_protection = false
  storage_encrypted = false

  # tags = local.tags
}

# Replica DB
module radius_replica_db {
  count = local.replicated ? 1 : 0
  # git clone https://github.com/terraform-aws-modules/terraform-aws-rds.git
  source = "./terraform-aws-rds"

  identifier = "${local.identifier}-replica"

  # Source database. For cross-region use db_instance_arn
  replicate_source_db = module.radius_master_db.db_instance_id
  create_random_password = false

  engine = local.engine
  engine_version = local.engine_version
  family = local.family
  major_engine_version = local.major_engine_version
  instance_class = local.instance_class
  parameters = local.parameters

  allocated_storage = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage

  # port = local.port

  multi_az = false
  vpc_security_group_ids = [data.aws_security_group.db_private_security_group.id]

  maintenance_window = local.maintenance_window
  backup_window = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  performance_insights_enabled = true
  performance_insights_retention_period = 7
  monitoring_role_arn = data.aws_iam_role.monitoring.arn
  monitoring_interval = 60

  backup_retention_period = 0
  skip_final_snapshot = true
  deletion_protection = false
  storage_encrypted = false

  # tags = local.tags
}

module master_friendly_domain {
  source = "../../../../../../modules/aws/dns-cname"
  domain_name = "${local.identifier}-master.${local.domain_suffix}"
  target = module.radius_master_db.db_instance_address
  root_domain = "vumaex.net"
  providers = {
    aws.dns = aws.dns
  }
}

module replicate_friendly_domain {
  count = local.replicated ? 1 : 0
  source = "../../../../../../modules/aws/dns-cname"
  domain_name = "${local.identifier}-replica.${local.domain_suffix}"
  target = module.radius_replica_db[0].db_instance_address
  root_domain = "vumaex.net"
  providers = {
    aws.dns = aws.dns
  }
}
