variable "azure_region" {
  type = string
}
variable "customer" {
  type = string
}
variable "purpose" {
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

variable "kind" {
  type    = string
  default = "StorageV2"
}
variable "tier" {
  type    = string
  default = "Standard"
}
variable "is_hns_enabled" {
  type    = bool
  default = true
}
variable "replication_type" {
  type    = string
  default = "LRS"
}
variable "min_tls_version" {
  type    = string
  default = "TLS1_2"
}
variable "shared_access_key_enabled" {
  type    = bool
  default = true
}
variable "allow_blob_public_access" {
  type    = bool
  default = false
}
variable "delete_retention_days" {
  type    = number
  default = 7
}
variable "access_tier" {
  type    = string
  default = "Hot"
}
variable "large_file_share_enabled" {
  type    = bool
  default = false
}

variable "keyvault_id" {
  type = string
}

variable "private_container_names" {
  type = list(any)
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
