module customer_gateway {
	source = "../../aws/customer-gateway"
	customer_gateway_ip = "196.25.143.99"
	customer_gateway_target = local.client
}

module easypay_vpn {
	source = "../../aws/vpn"
	name = "${var.name_prefix}-to-${local.client}"
	customer_gateway_id = module.customer_gateway.customer_gateway_id

	gateway_id = data.aws_vpn_gateway.vpc.id
	encryption_algorithms = ["AES256"]
	hash_algorithms = ["SHA1"]
	static_routes = local.easypay_cidr
}

// Sort out the route tables
data aws_route_tables integration {
	vpc_id = var.vpc_id
	tags = {
		"aex/integration": true
	}
}

resource aws_vpn_gateway_route_propagation easypay {
	for_each = toset(data.aws_route_tables.integration.ids)
	route_table_id = each.value
	vpn_gateway_id = data.aws_vpn_gateway.vpc.id
}

resource helm_release easypay_service {
	name = "easypay-service"
	chart = "${path.module}/helm"
	namespace = var.k8s_namespace
	set {
		name = "subnets"
		value = "{${join(", ", data.aws_subnets.integration.ids)}}"
	}
}

resource aws_vpn_gateway_route_propagation integration {
	for_each = toset(data.aws_subnets.all_integration.ids)
	route_table_id = data.aws_route_table.integration[each.value].route_table_id
	vpn_gateway_id = data.aws_vpn_gateway.vpc.id
}

module tunnel_state_alarm {
	source = "../../aws/cloudwatch-alarms/modules/alarm"
	alarm_name = "vpc-site-vpn-${var.name_prefix}-to-${local.client}-tunnel-state"
	comparison_operator = "LessThanThreshold"
	threshold = 1
	period = "300"
	evaluation_periods = 3
	datapoints_to_alarm = 3
	namespace = "AWS/VPN"
	metric_name = "TunnelState"
	dimensions = {
		VpnId = module.easypay_vpn.vpn_id
	}
	statistic = "Maximum"
	alarm_actions = var.alarm_actions
	ok_actions = var.ok_actions
	treat_missing_data = "breaching"
	tags = {
		category = "infrastructure"
	}
}
