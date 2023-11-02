module aex-sys-net {
	source = "./modules/zone"
	zone = "aex-sys.net"

	a_records = var.aex_sys_a_records
	c_names = var.aex_sys_c_names
	c_names_ttl = var.aex_sys_c_names_ttl
}

module aex-systems {
	source = "./modules/zone"
	zone = "aex.systems"

	a_records = var.aex_systems_a_records
	c_names = var.aex_systems_c_names
}

module automationexchange-tech {
	source = "./modules/zone"
	zone = "automationexchange.tech"

	a_records = var.automationexchange_tech_a_records
	c_names = var.automationexchange_tech_c_names
	mx = var.automationexchange_tech_mx
	srv = var.automationexchange_tech_srv
	txt = var.automationexchange_tech_txt
}
