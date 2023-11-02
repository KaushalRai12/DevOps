module port_forwarding_rule {
  count = var.security_group_id == null ? 0 : 1
  source = "../../../../../../../modules/aws/networking/modules/ingress-generic"
  ports = [var.destination_port == null ? var.source_port : var.destination_port]
  cidr = var.cidr
  protocol = var.protocol
  description = var.description
  security_group_id = var.security_group_id
}

resource aws_lb_target_group forwarding_destination {
  name = var.name == null ? "port-forwarding-${var.source_port}-${var.destination_port == null ? var.source_port : var.destination_port}" : var.name
  port = var.destination_port == null ? var.source_port : var.destination_port
  protocol = var.protocol
  vpc_id = module.constants_env.vpc_id
  target_type = var.target_type
  tags = var.extra_tags

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    port = var.health_check_port
    protocol = var.health_check_protocol
  }
}

resource aws_lb_target_group_attachment instance_attachment {
  for_each = var.target_ids
  target_group_arn = aws_lb_target_group.forwarding_destination.arn
  target_id = each.value
  port = var.destination_port
}

resource aws_lb_listener source_port_listener {
  load_balancer_arn = var.load_balancer_arn
  port = var.source_port
  protocol = var.protocol
  tags = var.extra_tags

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.forwarding_destination.arn
  }
}
