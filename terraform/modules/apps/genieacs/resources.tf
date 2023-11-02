// Only just copied from here: https://github.com/DrumSergio/genieacs-docker
resource helm_release mongo {
	name = "genieacs-mongo${local.name_suffix}"
	repository = "https://charts.bitnami.com/bitnami"
	chart = "mongodb"
	version = "10.31.4"
	namespace = var.namespace
	values = compact([
		templatefile("${path.module}/templates/values-mongo.yaml", {
			full_name: local.db_server,
			db_password_root : local.db_password_root,
			db_password_genieacs : local.db_password_genieacs,
		}),
		var.mongo_values
	])
}

resource helm_release genie {
	name = "genieacs${local.name_suffix}"
	chart = "${path.module}/helm"
	namespace = var.namespace
	values = compact([
		templatefile("${path.module}/templates/values-genie.yaml", {
			full_name: "genieacs${local.name_suffix}",
			db_server: local.db_server,
			db_password_genieacs : local.db_password_genieacs,
			jwt_secret: local.jwt_secret,
		}),
		var.genie_values
	])
}

resource helm_release nginx {
	name = "genieacs-nginx${local.name_suffix}"
	chart = "${path.module}/helm"
	namespace = var.namespace
	values = compact([
		templatefile("${path.module}/templates/values-nginx.yaml", {
			full_name: "genieacs-nginx${local.name_suffix}",
		}),
		var.nginx_values
	])
}

// Current routes:
// acs.stage.api.aex.co.za : http://acs.stage.aex-sys.net:7557 : NOT REGISTERED IN DNS
// acs.stage.ui.aex.co.za : http://acs.stage.aex-sys.net:3000
// acs.stage.cwmp.aex.co.za : http://acs.stage.aex-sys.net:7547
// acs.stage.fs.aex.co.za : http://acs.stage.aex-sys.net:7567 : NOT REGISTERED IN DNS
// where acs.stage.aex-sys.net is the current dev k8s-master
