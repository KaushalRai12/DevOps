variable aex_sys_a_records {
	description = "Create A Records with these values"
	type = map(string)
	default = {
		"": "41.79.241.26",
		"app01": "10.69.11.10",
		"app02": "10.69.11.18",
		"app03": "10.69.11.20",
		"app04": "10.69.11.24",
		"app05": "10.69.11.27",
		"app06": "10.69.11.40",
		"bld01": "10.69.11.14",
		"db01": "10.69.11.15",
		"db02": "10.69.11.35",
		"dev01": "10.69.11.17",
		"fs01": "10.69.11.21",
		"gitlab": "10.69.11.29",
		"redis": "10.69.11.37",
		// Kubernetes dev
		"k8s-master-01.dev": "10.69.11.19",
		"k8s-worker-01.dev": "10.69.11.37",
		"dev.k8s.virtual-ip": "10.69.11.210",
		// Kubernetes prod
		"k8s-master-01.prod": "10.69.11.12",
		"k8s-master-02.prod": "10.69.11.31",
		"k8s-master-03.prod": "10.69.11.32",
		"k8s-worker-01.prod": "10.69.11.30",
		"k8s-worker-02.prod": "10.69.11.38",
		"k8s.virtual-ip": "10.69.11.200",
		// Web servers
		"web01": "10.69.11.13",
		"web02": "10.69.11.16",
		"web03": "10.69.11.22",
		"web04": "10.69.11.33",
		// NMS
		"netstream_nms": "10.69.11.23",
		"speed-test-server": "10.69.11.43",
		// External
		//"nexus": "41.79.241.17",
		"pub1": "41.79.241.26",
		"pub2": "41.79.241.17",
		"stats": "41.79.241.144",
		"p7000.docker": "41.79.241.17",
		"p7001.docker": "41.79.241.17",
		"p7002.docker": "41.79.241.17",
		"p7003.docker": "41.79.241.17",
	}
}

variable aex_sys_c_names {
	description = "Create CNAME Records with these values"
	type = map(string)
	default = {
		"bastion": "aex-sys.net",
		"k8s-master-01": "k8s-master-01.prod.aex-sys.net",
		"k8s-master-02": "k8s-master-02.prod.aex-sys.net",
		"k8s-master-03": "k8s-master-03.prod.aex-sys.net",
		"k8s-worker-01": "k8s-worker-01.prod.aex-sys.net",
		"k8s-worker-02": "k8s-worker-02.prod.aex-sys.net",
		"els01": "k8s-master-01.prod.aex-sys.net",
		"els03": "dev.k8s.virtual-ip.aex-sys.net",
		"els02": "search-aex-staging-rrv3p2rsvxfuzer4bhdif6jhcm.af-south-1.es.amazonaws.com",
		"acs.stage": "dev.k8s.virtual-ip.aex-sys.net",
		"primary.radius": "vumatel-radius-primary-4b49135e810bb031.elb.af-south-1.amazonaws.com",
		"secondary.radius": "vumatel-radius-primary-4b49135e810bb031.elb.af-south-1.amazonaws.com",
		// todo: deprecate - must use k8s-api
		"k8s-api.prod": "k8s.virtual-ip.aex-sys.net",
	}
}

variable aex_sys_c_names_ttl {
	description = "Create CNAME Records with these values and TTL"
	type = map(tuple([string, number]))
	default = {
		"dev.k8s": ["dev.k8s.virtual-ip.aex-sys.net", 600],
		"k8s": ["k8s-master-01.prod.aex-sys.net", 600],
		"k8s-api": ["k8s.virtual-ip.aex-sys.net", 600],
		"dev.k8s-api": ["k8s-master-01.dev.aex-sys.net", 600],
	}
}
