# constants
locals {
	devops_email = "jrgns@aex.co.za"
	nat_instance_ami = "ami-085895de667406610"

	aex_remote_vpn_cidr = "10.49.149.0/24"
	aex_rbk_vm_cidr = "10.69.11.0/24"
	reflex_firewall_cidr = "154.72.6.178/32"
	aex_exchange_server_cidr = "10.69.10.125/32"
	aex_siem_server_cidr = "10.69.10.26/32"
	operations_cidr = "10.184.64.0/18"
	transit_cidr = "10.9.0.0/24"

	aex_rbk_ssrs_cidr = "10.69.11.17/32"
	aex_rbk_db01_cidr = "10.69.11.15/32"
	
	vumatel_remote_vpn_cidr = "10.88.0.0/21"
	vumatel_cms_cidr = "10.88.10.55/32"
	vumatel_nce_cidr = "10.88.12.0/24"
	vumatel_zms_cidr = "10.88.10.55/32" # TBD
	vumatel_wc_bng_cidrs = [
		"160.119.142.216/29", # Juniper
		"10.88.67.0/24", # Huawei
	]
	vumatel_gp_bng_cidrs = [
		"102.67.182.64/29", # Juniper
		"10.88.35.0/24", # Huawei
	]
	vumatel_kzn_bng_cidrs = [
		"41.242.173.16/28", # Juniper
		"10.104.48.0/24", # Huawei
	]
	vumatel_prtg_cidrs = [
		"41.222.137.39/32", # WC-TRCT-PRTG1
		"102.220.178.92/32", # WC-BKFL-PRTG1
	]
	vumatel_speed_test_cidrs = [
		"10.104.0.0/16", # Mikrotik BNG
	]
	vumatel_remote_data_users_cidrs = [
		"20.87.15.77/32", # Revenue Assurance
		"172.255.254.4/32", # Revenue Assurance. Shouldn't it be the one above?
		"102.220.176.38/32", # Vumatel Office
		"102.165.195.218/32", # Sherwin
		"169.0.188.176/32", # Queado (Yoni / Werena)
		"10.184.8.108/32", # DMS
		"10.184.8.239/32", # Load Balancer (Fixed IP Ingress)
		"10.184.9.100/32", # Load Balancer (Fixed IP Ingress)
		"34.246.74.86/32", # Vumatel Data Science tableau 1
		"52.215.158.213/32", #  Vumatel Data Science tableau 2
	]
	vumatel_vmware_speed_test_ips = [
		{
			zone = "jhb"
			ip = "102.220.176.3"
		},
		{
			zone = "cpt"
			ip = "102.220.178.3"
		},
		{
			zone = "dbn"
			ip = "102.220.179.3"
		}
	]

	aex_vpn_cidrs = [
		# local.aex_remote_vpn_cidr,
		# local.aex_rbk_vm_cidr,
		# local.reflex_firewall_cidr,
		# local.aex_exchange_server_cidr,
		# local.aex_siem_server_cidr,
	]

	aex_access_cidrs = [
		# local.aex_remote_vpn_cidr, # TODO Remove this once the vumatel VPN access has been confirmed
	]

	vumatel_data_access_cidrs = setunion(
		[
			local.vumatel_remote_vpn_cidr,
		],
		local.vumatel_remote_data_users_cidrs,
	)

	vumatel_access_cidrs = [
		local.vumatel_remote_vpn_cidr,
	]

	vumatel_nms_cidrs = [
		local.vumatel_cms_cidr,
		local.vumatel_nce_cidr,
		# local.vumetal_zms_cidr,
	]

	vumatel_bng_cidrs = setunion(
		local.vumatel_wc_bng_cidrs,
		local.vumatel_gp_bng_cidrs,
		local.vumatel_kzn_bng_cidrs,
		local.vumatel_speed_test_cidrs,
	)

	# Used for Geo whitelisting in WAF rules
	static_ips = [
	]

	aex_i11l_client_facing_domain = "vumaex.co.za"
	aex_i11l_systems_domain = "vumaex.net"
	aex_i11l_internal_api_domain = "vumaex.internal"
	aex_i11l_infrastructure_domain = "vumaex.blue"
	aex_rbk_internal_domain = "aex-sys.net"
	aex_za_client_facing_domain = "vumaex.co.za"
	aex_za_public_domain = "vumaex.co.za"
	aex_legacy_domain = "aex.co.za"

	region_tz = {
		af-south-1 : "Africa/Johannesburg"
		us-west-1 : "America/Los_Angeles"
		us-west-2 : "America/Los_Angeles"
		us-east-1 : "America/New_York"
	}

	ec2_instance_role = "aex-ec2-instance-role"
	transit_vpn_id_rosebank = "vpn-0460297d02d929016"
}

output aex_access_cidrs {
	value = toset(local.aex_access_cidrs)
}

output vumatel_data_access_cidrs {
	value = toset(local.vumatel_data_access_cidrs)
}

output vumatel_access_cidrs {
	value = toset(local.vumatel_access_cidrs)
}

output aex_vpn_cidrs {
	value = toset(local.aex_vpn_cidrs)
}

output aex_rbk_vm_cidr {
	value = local.aex_rbk_vm_cidr
}

output db_access_cidrs {
	# TODO Cleanup
	value = toset([local.vumatel_remote_vpn_cidr])
	# value = toset([local.aex_remote_vpn_cidr, local.vumatel_remote_vpn_cidr, local.aex_rbk_db01_cidr, local.aex_rbk_ssrs_cidr])
}

output route53_domains {
	value = [
		local.aex_i11l_client_facing_domain,
		local.aex_i11l_systems_domain,
		local.aex_i11l_infrastructure_domain,
		local.aex_i11l_internal_api_domain,
		local.aex_za_client_facing_domain,
		local.aex_legacy_domain,
	]
}

output aex_i11l_client_facing_domain {
	value = local.aex_i11l_client_facing_domain
}

output aex_i11l_systems_domain {
	value = local.aex_i11l_systems_domain
}

output aex_i11l_infrastructure_domain {
	value = local.aex_i11l_infrastructure_domain
}

output aex_i11l_internal_api_domain {
	value = local.aex_i11l_internal_api_domain
}

output aex_rbk_internal_domain {
	value = local.aex_rbk_internal_domain
}

output aex_za_public_domain {
	value = local.aex_za_public_domain
}

output aex_za_client_facing_domain {
	value = local.aex_za_client_facing_domain
}

output region_tz {
	value = local.region_tz
}

output ec2_instance_profile {
	value = "aex-ec2-instance-profile"
}

output eks_node_instance_policy {
	value = "aex-eks-node-instance"
}

output max_lb_certificates {
	value = 25
}

output aex_siem_server_cidr {
	value = local.aex_siem_server_cidr
}

output vumatel_bng_cidrs {
	value = local.vumatel_bng_cidrs
}

output vumatel_prtg_cidrs {
	value = local.vumatel_prtg_cidrs
}

output vumatel_remote_vpn_cidr {
	value = local.vumatel_remote_vpn_cidr
}

output manual_backups_role {
	value = "aex-manual-backups"
}

output operations_cidr {
	value = local.operations_cidr
}

output transit_vpn_id_rosebank {
	value = local.transit_vpn_id_rosebank
}

output static_ips {
	value = local.static_ips
}

output aex_legacy_domain {
	value = local.aex_legacy_domain
}

output devops_email {
	value = local.devops_email
}

output vumatel_vmware_speed_test_ips {
	value = local.vumatel_vmware_speed_test_ips
}