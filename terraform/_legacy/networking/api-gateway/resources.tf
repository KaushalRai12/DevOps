resource "helm_release" "ambassador" {
	name = "ambassador"
	repository = "https://www.getambassador.io"
	chart = "ambassador"
	version = "6.5.19"
	namespace = "aex-stage"
	values = [
		file("values.yaml"),
	]
}

/*
resource "helm_release" "ambassador_prod" {
	provider = helm.prod
	name = "ambassador"
	repository = "https://charts.helm.sh/stable"
	chart = "nfs-client-provisioner"
	version = "1.0.1"
	namespace = "aex-devops"
	values = [
		file("values.yaml"),
	]
	set {
		name = "nfs.server"
		value = "10.69.11.27"
	}
}
*/

