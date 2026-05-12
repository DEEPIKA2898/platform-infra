variable "workspace_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  type    = string
  default = "premium"
}

variable "vnet_id" {
  type = string
}

variable "public_subnet_name" {
  type = string
}

variable "private_subnet_name" {
  type = string
}

variable "public_nsg_assoc_id" {
  type = string
}

variable "private_nsg_assoc_id" {
  type = string
}

variable "log_analytics_id" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}