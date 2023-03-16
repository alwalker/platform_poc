variable "azure_region" {
  type = string
}
variable "env" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "default_tags" {
  type = map(any)
}

variable "keyvault_id" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "GP_Gen5_2"
}
variable "engine_version" {
  type    = string
  default = "11"
}
variable "storage_size" {
  type    = number
  default = 262144
}
variable "backup_retention_days" {
  type    = number
  default = 7
}
variable "geo_redundant_backup" {
  type    = bool
  default = true
}
variable "admin_username" {
  type = string
}
variable "auto_grow_enabled" {
  type    = bool
  default = true
}
variable "public_network_access_enabled" {
  type    = bool
  default = false
}
variable "ssl_enforcement_enabled" {
  type    = bool
  default = true
}
variable "ssl_minimal_tls_version_enforced" {
  type    = string
  default = "TLS1_2"
}

variable "pe_subnet_name" {
  type = string
}
variable "vnet_name" {
  type = string
}
variable "dns_zone_id" {
  type = string
}

variable "dns_zone_name" {
  type = string
}
