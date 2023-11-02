resource helm_release sonarqube {
	name = "sonarqube"
	repository = "https://oteemo.github.io/charts"
	chart = "sonarqube"
	version = "9.5.1"
	namespace = "aex-devops"
	values = [
		file("${path.module}/templates/values-sonarqube.yaml")
	]
}

resource helm_release nexus {
	name = "nexus"
	repository = "https://openchart.choerodon.com.cn/choerodon/c7n"
	chart = "sonatype-nexus"
	version = "3.4.0"
	namespace = "aex-devops"
	values = [
		file("${path.module}/templates/values-nexus.yaml")
	]
}

