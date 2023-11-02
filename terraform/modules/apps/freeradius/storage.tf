# resource aws_efs_file_system radius_shared_storage {
# 	creation_token = "${var.cluster_fqn}_efs"
# 	performance_mode = "generalPurpose"
# 	throughput_mode = "bursting"
# 	encrypted = "true"

# 	tags = {
# 		Name = "${var.cluster_fqn}_efs"
# 	}
# }

# resource aws_efs_mount_target efs_mount_target {
# 	file_system_id = aws_efs_file_system.radius_shared_storage.id
# 	security_groups = [aws_security_group.efs.id]
# 	subnet_id = var.subnet
# }
