variable "azure_region" {
  type = string
}
variable "env" {
  type = string
}
variable "customer" {
  type = string
}
variable "retention_in_days" {
  type    = number
  default = 7
}
variable "purge_protection_enabled" {
  type    = bool
  default = false
}
variable "enable_rbac_authorization" {
  type    = bool
  default = false
}
variable "sku_name" {
  type    = string
  default = "standard"
}
variable "access_policies" {
  type = map(object({
    object_id               = string
    secret_permissions      = list(string)
    key_permissions         = list(string)
    storage_permissions     = list(string)
    certificate_permissions = list(string)
  }))
  default = {}
}
variable "resource_group_name" {
  type = string
}
variable "default_tags" {
  type = map(any)
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
