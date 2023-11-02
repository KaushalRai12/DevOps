module main {
	source = "../common"

	plan_name = local.backup_plan_name
	cluster_env = var.cluster_env
	backup_type = "rds"

	backup_key_arn = var.backup_key_arn
	backup_role_arn = var.backup_role_arn
	sns_topic_arn = var.sns_topic_arn

	rules = local.rules
}
