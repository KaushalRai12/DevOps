locals {
    image_tag = "1.0.14"
}

module constants_cluster {
	source = "../../../../modules/constants"
}

module constants_env {
	source = "../../modules/constants"
}
