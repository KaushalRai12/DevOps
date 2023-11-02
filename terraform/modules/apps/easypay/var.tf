variable vpc_id {
	description = "VPC Id"
	type = string
}

variable name_prefix {
	description = "VPN name prefix"
	type = string
}

variable k8s_namespace {
	description = "Target namespace for the easypay k8s service"
	type = string
}

variable is_multi_zone {
	description = "Whether to multi-zone the load balancer"
	type = bool
	default = true
}

variable easypay_cidr {
	description = "The remote EasyPay CIDR"
	type = string
	default = "196.34.51.0/24" # EasyPay testing CIDR
}

variable alarm_actions {
	description = "Array of actions, typically the ARNs of SNS topics, to trigger when an alarm goes into the Alarm state"
	type = set(string)
	default = ["arn:aws:sns:af-south-1:774405590946:cloudwatch-alarms"]
}

variable ok_actions {
	description = "Array of actions, typically the ARNs of SNS topics, to trigger when an alarm goes into the OK state"
	type = set(string)
	default = ["arn:aws:sns:af-south-1:774405590946:cloudwatch-alarms"]
}

locals {
	client = "easypay"
	easypay_cidr = [var.easypay_cidr]
}

data aws_vpn_gateway vpc {
	attached_vpc_id = var.vpc_id
}

data aws_subnets integration {
	filter {
		name = "vpc-id"
		values = [var.vpc_id]
	}
	tags = merge({
		"aex/nms": true
		"aex/integration" : true
	}, var.is_multi_zone ? {} : tomap({"aex/az" = "a"}))
}

data aws_subnets all_integration {
	filter {
		name = "vpc-id"
		values = [var.vpc_id]
	}
	tags = merge({
		"aex/integration" : true
	}, var.is_multi_zone ? {} : tomap({"aex/az" = "a"}))
}

data aws_route_table integration {
	for_each = toset(data.aws_subnets.all_integration.ids)
	subnet_id = each.value
}
