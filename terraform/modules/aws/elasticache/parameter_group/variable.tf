variable name {
  type = string
  description = "Name of the elasticache parameter group"
}

variable family {
  type = string
  description = "Engine family of the elasticache parameter group"
}

variable description {
  type = string
  default = null 
}

variable parameters {
  type = list(object({
    name = string,
    value = string
  }))
  description = "Custom Elasticache parameters"
  default = []
}
