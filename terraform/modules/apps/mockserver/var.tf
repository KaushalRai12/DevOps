variable "namespace" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "environment" {
  type = string
}

locals {
	name = "mock-server"
  repository = "gitlab.vumaex.net:4567/internal/devops/mock-server"
}

