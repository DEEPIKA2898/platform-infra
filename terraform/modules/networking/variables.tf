variable "name" {
  type        = string
  description = "Base name for networking resources"
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_address_space" {
  type    = string
  default = "10.20.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.20.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.20.2.0/24"
}

variable "tags" {
  type    = map(string)
  default = {}
}