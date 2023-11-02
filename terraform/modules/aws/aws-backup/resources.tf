resource aws_sns_topic default {
	name = "backup-events-${var.cluster_env}"
	kms_master_key_id = data.aws_kms_key.sns_backup.arn
}

resource aws_sns_topic_policy default {
	arn = aws_sns_topic.default.arn
	policy = data.aws_iam_policy_document.sns_policy.json
}

resource aws_iam_role default {
	name = "aex-backup-role-${var.cluster_env}"
	assume_role_policy = data.aws_iam_policy_document.default.json
}

resource aws_iam_role_policy_attachment default_role_policy_attach {
	policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
	role = aws_iam_role.default.name
}

resource aws_iam_policy default_custom_policy {
	description = "AWS Backup Tag policy (${var.cluster_env})"
	policy = data.aws_iam_policy_document.tagging.json
}

resource aws_iam_role_policy_attachment default_custom_policy_attach {
	policy_arn = aws_iam_policy.default_custom_policy.arn
	role = aws_iam_role.default.name
}

module ebs {
	source = "./modules/ebs"
	cluster_env = var.cluster_env
	backup_key_arn = data.aws_kms_key.backup.arn
	weekly_backup_ttl = var.ebs_weekly_backup_ttl
	sns_topic_arn = aws_sns_topic.default.arn
	backup_role_arn = aws_iam_role.default.arn
}

module rds {
	source = "./modules/rds"
	cluster_env = var.cluster_env
	backup_key_arn = data.aws_kms_key.backup.arn
	sns_topic_arn = aws_sns_topic.default.arn
	backup_role_arn = aws_iam_role.default.arn
	hourly_backup_ttl = var.rds_hourly_backup_ttl
	daily_backup_ttl = var.rds_daily_backup_ttl
	weekly_backup_ttl = var.rds_weekly_backup_ttl
}
