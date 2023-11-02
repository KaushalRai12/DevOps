variable automationexchange_tech_a_records {
	description = "Create A Records with these values"
	type = map(string)
	default = {
		"": "154.72.6.221"
		"ftp": "41.79.241.144"
		"wwwintertech": "41.79.241.144"
	}
}

variable automationexchange_tech_c_names {
	description = "Create CNAME Records with these values"
	type = map(string)
	default = {
		"_4f910e3b6cf7e15671ae5f8413745f3c.www.automationexchange.tech": "d1ac7850439d2ac7a0a6b4c0a2fc47c6.f077ca3129fc9b1363ca84fa74c2a786.ee812d04b09fc5eab089.comodoca.com"
		"_a98f201ecab1320718c2e35fd21cafdb.automationexchange.tech": "5c41a863f8850a28f1fbbe440bd8ad08.e57639b59a4fc037b1d8c35ff4728a70.39ba31c76f5b8342fdcc.comodoca.com"
		"autodiscover.automationexchange.tech": "autodiscover.outlook.com"
		"_fbe9926cc25a20b38becc81ed28efc3f.automationexchange.tech": "c0d8868f3212a0203b8202fd1dd7de29.c31bd6ecf1e0613f5d6e860b51cb4c7b.f998fab78920ef695e32.comodoca.com"
		"_fbe9926cc25a20b38becc81ed28efc3f.www.automationexchange.tech": "c0d8868f3212a0203b8202fd1dd7de29.c31bd6ecf1e0613f5d6e860b51cb4c7b.f998fab78920ef695e32.comodoca.com"
		"www.automationexchange.tech": "automationexchange.tech",
		"4tzyk77g2zm7ngj7lkyh3zc3qu6ljwtd._domainkey.automationexchange.tech": "4tzyk77g2zm7ngj7lkyh3zc3qu6ljwtd.dkim.amazonses.com",
		"thrbntgn5kwora3nn72sqzffq5gneaps._domainkey.automationexchange.tech": "thrbntgn5kwora3nn72sqzffq5gneaps.dkim.amazonses.com",
		"hh7c7tqd35gfl7vqqjloo4wvrb6znp3c._domainkey.automationexchange.tech": "hh7c7tqd35gfl7vqqjloo4wvrb6znp3c.dkim.amazonses.com",
	}
}

variable automationexchange_tech_mx {
	description = "Create MX Records with these values"
	type = map(string)
	default = {
		"automationexchange.tech": "1 automationexchange-tech.mail.protection.outlook.com"
		"notifications.automationexchange.tech": "10 feedback-smtp.us-east-1.amazonses.com"
	}
}

variable automationexchange_tech_txt {
	description = "Create TXT Records with these values"
	type = map(list(string))
	default = {
		"automationexchange.tech": ["v=spf1 include:spf.protection.outlook.com -all", "MS=ms44751585"]
		"notifications.automationexchange.tech": ["v=spf1 include:amazonses.com ~all"]
	}
}

variable automationexchange_tech_srv {
	description = "Create SRV Records with these values"
	type = map(string)
	default = {
		"_autodiscover._tcp.automationexchange.tech": "1 1 443 autodiscover.altostratus.co"
	}
}


