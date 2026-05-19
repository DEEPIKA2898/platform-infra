variable "environment" {
  type = string
}

variable "max_workers" {
  type    = number
  default = 4
}

variable "min_workers" {
  type    = number
  default = 1
}

variable "node_type" {
  type    = string
  default = "Standard_D4s_v3"
}

variable "spark_version" {
  type    = string
  default = "14.3.x-scala2.12"
}

variable "tags" {
  type    = map(string)
  default = {}
}