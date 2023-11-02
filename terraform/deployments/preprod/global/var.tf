locals {
	limit_amount = "2250"
}

module constants_cluster {
	source = "../modules/constants"
}

module constants {
	source = "../../../modules/aws/constants"
}
