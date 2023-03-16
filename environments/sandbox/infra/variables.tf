#TODO this should probably always be the global shared keyvault
variable "keyvault_id" {
  type    = string
}

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
variable "default_env_tags" {
  type = map(any)
}

variable "db_admin_name" {
  type = string
}
variable "pg_private_dns_zone_name" {
  type = string
}
variable "pg_private_dns_zone_id" {
  type = string
}
