variable aex_systems_a_records {
	description = "Create A Records with these values"
	type = map(string)
	default = {
		"preprod.portal-dbms.vumatel": "41.79.241.26"
		"k8s-rosebank": "41.79.241.26"
	}
}

variable aex_systems_c_names {
	description = "Create CNAME Records with these values"
	type = map(string)
	default = {
		"acs": "acs.stage.cwmp.aex.co.za",
		"net99.acs": "acs.stage.cwmp.aex.co.za",
		"ofus.acs": "acs.stage.cwmp.aex.co.za",
		"zoomfibre.acs": "13.244.235.169:9675/live/CPEManager/CPEs/genericTR69"
	}
}
