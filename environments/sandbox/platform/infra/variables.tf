variable "azure_region" {
  type = string
}
variable "env" {
  type = string
}
variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "storage_private_dns_zone_name" {
  type = string
}
variable "storage_private_dns_zone_id" {
  type = string
}

variable "keyvault_private_dns_zone_name" {
  type = string
}
variable "keyvault_private_dns_zone_id" {
  type = string
}

variable "default_env_tags" {
  type = map(any)
  default = {
    ProductCategory = "Dfs"
  }
}

variable "customer" {
  type    = string
  default = "CE"
}

variable "default_customer_tags" {
  type = map(any)
  default = {
    ServiceType = "SharedKubernetes"
  }
}

#TODO this should probably always be the global shared keyvault
variable "global_keyvault_id" {
  type    = string
}
