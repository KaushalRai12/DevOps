module constants {
	source = "../../../../../modules/aws/constants"
}

data aws_route53_zone zone {
	name = module.constants.aex_legacy_domain
}

locals {
	gearsoft_ns_records = [
		"ns-1324.awsdns-37.org",
		"ns-1617.awsdns-10.co.uk",
		"ns-808.awsdns-37.net",
		"ns-40.awsdns-05.com",
	]

	gs_web_01 = "41.79.241.26"
	gs_web_03 = "41.79.241.17"
	gs_reflex = "41.79.241.144"
	gs_web_04 = "154.119.253.238"
	gs_website = "154.72.6.221"

	c_names = {
		"autodiscover.aex.co.za": "autodiscover.outlook.com.",
		"mail.aex.co.za": "mail.reflex.co.za.",
		"mails.aex.co.za": "r.eu-west-1.awstrack.me.",
		"selector1._domainkey.aex.co.za": "selector1-aex-co-za._domainkey.vumatelcoza.onmicrosoft.com",
		"selector2._domainkey.aex.co.za": "selector2-aex-co-za._domainkey.vumatelcoza.onmicrosoft.com",
		"enterpriseregistration.aex.co.za": "enterpriseregistration.windows.net",
		"enterpriseenrollment.aex.co.za": "enterpriseenrollment.manage.microsoft.com",

		"speed.vumatel.aex.co.za": "portal.vumatel.aex.co.za",
		"vumatel.aex.co.za": "portal.vumatel.aex.co.za",
		"aerial-shop.vumatel.aex.co.za": "portal.vumatel.aex.co.za",
		"mpf.aex.co.za": "portal.vumatel.aex.co.za",
		"_dmarc.aex.co.za": "aex.co.za.dmarc.sdmarc.net."
	}

	srv_records = {
		"_autodiscover._tcp.aex.co.za": "0 0 443 autodiscover.altostratus.co."
	}

	mx_records = {
		"aex.co.za": "0 aex-co-za.mail.protection.outlook.com."
	}

	a_records = {
		"speedtests.aex.co.za": local.gs_web_01,
		"aex.co.za": local.gs_website,
		"www.aex.co.za": local.gs_website,
		# "internal.vumatel.aex.co.za": local.gs_web_01,
	}

	txt_records = {
		"_acme-challenge.aex.co.za": ["XGqv2yz0EhEVNAwT9H8grNRRWO8tPVw4xjP3va-3aqI"],
		"_amazonses.aex.co.za": ["ZuwLAITBv1kQSryBaEOKs+iDM250TDMPkDzMlROaqzg="],
		"aex.co.za": [
			"v=spf1 include:spf.protection.outlook.com ip4:197.234.130.65 -all",
			# "MS=ms73336108", # Reflex Office365 # TODO
			"google-site-verification=58eh9UQZ1OWj1xGaweSFMaW4OJNURn6hDa7D2_YsSs8",
			"MS=ms11683918", # Vumatel Office365
		]
	}

	gearsoft_delegated_a_records = {
		"accesspoint.aex.co.za": local.gs_web_01,
		"admin.aex.co.za": local.gs_web_01,
		"apitest.mockfno.aex.co.za": local.gs_web_03,
		"app.aex.co.za": local.gs_web_01,
		"app.netninenine.aex.co.za": local.gs_web_01,
		"boleng.aex.co.za": local.gs_web_01,
		"boleng.installer.aex.co.za": local.gs_web_01,
		"client-interface.aex.co.za": local.gs_web_01,
		"client.evotel-isp.aex.co.za": local.gs_web_01,
		"client.metrowatt.aex.co.za": local.gs_web_01,
		"client.reflex.aex.co.za": local.gs_web_01,
		"cpe.aex.co.za": local.gs_web_01,
		"dbredux.fno.aex.co.za": local.gs_web_03,
		"dbredux.mockfno.aex.co.za": local.gs_web_01,
		"dev.fno.aex.co.za": local.gs_web_03,
		"evotel-isp.aex.co.za": local.gs_web_01,
		"evotel.aex.co.za": local.gs_web_01,
		"evotel.app.aex.co.za": local.gs_web_01,
		"evotel.client-interface.aex.co.za": local.gs_web_01,
		"evotel.fno.aex.co.za": local.gs_web_01,
		"evotel.installer.aex.co.za": local.gs_web_01,
		"fno-frontend.aex.co.za": local.gs_web_04,
		"fno.aex.co.za": local.gs_web_04,
		"installer.aex.co.za": local.gs_web_03,
		"isp-interface.aex.co.za": local.gs_web_01,
		"isp-proxy-service.aex.co.za": local.gs_web_01,
		"katiah.aex.co.za": local.gs_web_01,
		"linklayer.aex.co.za": local.gs_web_01,
		"linklayer.fno.aex.co.za": local.gs_web_01,
		"linklayer.installer.aex.co.za": local.gs_web_01,
		"maboneng.installer.aex.co.za": local.gs_web_01,
		"magnoliatreefibre.aex.co.za": local.gs_web_01,
		"magnoliatreefibre.installer.aex.co.za": local.gs_web_01,
		"metrowatt.aex.co.za": local.gs_web_01,
		"metrowatt.client-interface.aex.co.za": local.gs_web_01,
		"metrowatt.installer.aex.co.za": local.gs_web_01,
		"mfibre.aex.co.za": local.gs_web_01,
		"mockfno.aex.co.za": local.gs_web_01,
		"mockfno.client-interface.aex.co.za": local.gs_web_01,
		"mockfno.installer.aex.co.za": local.gs_web_01,
		"monitoring.aex.co.za": "41.79.240.244",
		"net99-jhb.radius.aex.co.za": local.gs_web_04,
		"netninenine.client-interface.aex.co.za": local.gs_web_01,
		"netninenine.installer.aex.co.za": local.gs_web_01,
		"netstream.aex.co.za": local.gs_web_01,
		"netstream.installer.aex.co.za": local.gs_web_01,
		"openfibre.fno.aex.co.za": local.gs_web_01,
		"openfibre.installer.aex.co.za": local.gs_web_01,
		"payment-service.aex.co.za": local.gs_web_01,
		"preprod.status.aex.co.za": local.gs_web_01,
		"prtg-monitoring.aex.co.za": "10.69.10.95",
		"ptzambia.aex.co.za": local.gs_web_01,
		"ptzambia.installer.aex.co.za": local.gs_web_01,
		"public.fno.aex.co.za": local.gs_web_01,
		"purchase-service.aex.co.za": local.gs_web_01,
		"risetelecoms.aex.co.za": local.gs_web_01,
		"risetelecoms.installer.aex.co.za": local.gs_web_01,
		"search.aex.co.za": local.gs_web_01,
		"security.aex.co.za": local.gs_web_01,
		"skyfi.aex.co.za": local.gs_web_01,
		"skyfi.installer.aex.co.za": local.gs_web_01,
		"stats.accesspoint.aex.co.za": local.gs_reflex,
		"stats.aex.co.za": local.gs_reflex,
		"stats.app.aex.co.za": local.gs_reflex,
		"stats.client-interface.aex.co.za": local.gs_reflex,
		"stats.fno.aex.co.za": local.gs_reflex,
		"status.aex.co.za": local.gs_web_04,
		"support-interface.aex.co.za": local.gs_web_01,
		"walix.installer.aex.co.za": local.gs_web_01,
		"zoomfibre.aex.co.za": local.gs_web_01,
		"zoomfibre.client-interface.aex.co.za": local.gs_web_01,
		"zoomfibre.fno.aex.co.za": local.gs_web_01,
		"zoomfibre.installer.aex.co.za": local.gs_web_01,		
	}

	# gearsoft_a_records = {
	# 	"acs.stage.cwmp.aex.co.za": local.gs_web_03,
	# 	"acs.stage.ui.aex.co.za": local.gs_web_03,
	# 	"cadvisor.aex.co.za": local.gs_web_03,
	# 	"client.aex.co.za": local.gs_web_01,
	# 	"dbredux.aex.co.za": local.gs_web_03,
	# 	"dna.aex.co.za": local.gs_web_01,
	# 	"dotnet-toolbox.tech-docs.aex.co.za": local.gs_web_03,
	# 	"frontend.aex.co.za": local.gs_web_04,
	# 	"infraplex.aex.co.za": local.gs_web_01,
	# 	"ip-pools.aex.co.za": local.gs_web_01,
	# 	"isp.aex.co.za": local.gs_web_01,
	# 	"lanseria.aex.co.za": local.gs_web_03,
	# 	"maboneng.aex.co.za": local.gs_web_01,
	# 	"meshtelecom.aex.co.za": local.gs_web_01,
	# 	"metrofibre.aex.co.za": local.gs_web_01,
	# 	"mtn.aex.co.za": local.gs_web_01,
	# 	"netninenine.aex.co.za": local.gs_web_01,
	# 	"ngx-toolbox.tech-docs.aex.co.za": local.gs_web_03,
	# 	"openfibre.aex.co.za": local.gs_web_01,
	# 	"ops-dashboard.aex.co.za": local.gs_web_03,
	# 	"prepaid.aex.co.za": local.gs_web_04,
	# 	"triage.aex.co.za": local.gs_web_01,
	# 	"upsource.aex.co.za": local.gs_web_03,
	# 	"walix.aex.co.za": local.gs_web_01,
	# 	"workflowserver.aex.co.za": local.gs_web_03,
	# }

	gearsoft_subdomains = {
		"accesspoint": local.gearsoft_ns_records,
		"admin": local.gearsoft_ns_records,
		"app": local.gearsoft_ns_records,
		"app.netninenine": local.gearsoft_ns_records,
		"boleng": local.gearsoft_ns_records,
		"client-interface": local.gearsoft_ns_records,
		"cpe": local.gearsoft_ns_records,
		"events": local.gearsoft_ns_records,
		"evotel": local.gearsoft_ns_records,
		"evotel-isp": local.gearsoft_ns_records,
		"fno": local.gearsoft_ns_records,
		"fno-frontend": local.gearsoft_ns_records,
		"gstest": local.gearsoft_ns_records,
		"installer": local.gearsoft_ns_records,
		"isp-interface": local.gearsoft_ns_records,
		"isp-proxy-service": local.gearsoft_ns_records,
		"katiah": local.gearsoft_ns_records,
		"linklayer": local.gearsoft_ns_records,
		"magnoliatreefibre": local.gearsoft_ns_records,
		"metrowatt": local.gearsoft_ns_records,
		"mfibre": local.gearsoft_ns_records,
		"mockfno": local.gearsoft_ns_records,
		"monitoring": local.gearsoft_ns_records,
		"net99-jhb.radius": local.gearsoft_ns_records,
		"netstream": local.gearsoft_ns_records,
		"nstest": local.gearsoft_ns_records,
		"payment-service": local.gearsoft_ns_records,
		"prtg-monitoring": local.gearsoft_ns_records,
		"ptzambia": local.gearsoft_ns_records,
		"purchase-service": local.gearsoft_ns_records,
		"reflex": local.gearsoft_ns_records,
		"risetelecoms": local.gearsoft_ns_records,
		"search": local.gearsoft_ns_records,
		"security": local.gearsoft_ns_records,
		"skyfi": local.gearsoft_ns_records,
		"stats": local.gearsoft_ns_records,
		"status": local.gearsoft_ns_records,
		"support-interface": local.gearsoft_ns_records,
		"zoomfibre": local.gearsoft_ns_records,
  }
}
