resource "helm_release" "all_roles_prod" {
	name = "global-roles"
	chart = "./helm"
	namespace = "aex-devops"
	set {
		name = "user.clusterSuffix"
		value = "-prod"
	}
}
