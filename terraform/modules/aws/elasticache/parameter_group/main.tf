resource "aws_elasticache_parameter_group" "parameter_group" {
  name        = var.name
  description = var.description
  family = var.family

  dynamic "parameter" {
    for_each = var.parameters

    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}
