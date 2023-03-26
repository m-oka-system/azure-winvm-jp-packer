variable "project" {
  type = string
}

variable "location" {
  type = string
  default = "japaneast"
}

variable "resource_group_name" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "gallery_name" {
  type = string
}

variable "image_definition" {
  type = string
}

variable "image_version" {
  type = string
}

variable "replication_regions" {
  type = list(string)
  default = ["japaneast"]
}

variable "winrm_password" {
  type = string
}

variable "inbound_ip_addresses" {
  type = list(string)
}

# variable "virtual_network_name" {
#   type = string
# }

# variable "virtual_network_subnet_name" {
#   type = string
# }

# variable "virtual_network_resource_group_name" {
#   type = string
# }

