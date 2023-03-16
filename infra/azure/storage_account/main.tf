resource "azurerm_storage_account" "main" {
  name                = lower("${var.env}${var.customer}${var.purpose}")
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  account_tier             = var.tier
  account_kind             = var.kind
  account_replication_type = var.replication_type
  access_tier              = var.access_tier
  is_hns_enabled           = var.is_hns_enabled

  enable_https_traffic_only = true
  min_tls_version           = var.min_tls_version
  allow_blob_public_access  = var.allow_blob_public_access
  shared_access_key_enabled = var.shared_access_key_enabled
  large_file_share_enabled  = var.large_file_share_enabled

  tags = { for k, v in var.default_tags : k => v }
}
resource "azurerm_key_vault_secret" "storage_account_key_1" {
  name         = "${var.env}-${var.customer}-storage-account-key-1"
  value        = azurerm_storage_account.main.primary_access_key
  key_vault_id = var.keyvault_id
}
resource "azurerm_key_vault_secret" "storage_account_key_2" {
  name         = "${var.env}-${var.customer}-storage-account-key-2"
  value        = azurerm_storage_account.main.secondary_access_key
  key_vault_id = var.keyvault_id
}

data "azurerm_subnet" "storage_pe_subnet" {
  name                 = var.pe_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}
resource "azurerm_private_endpoint" "main" {
  name                = "${azurerm_storage_account.main.name}-blob"
  resource_group_name = var.resource_group_name
  location            = var.azure_region
  subnet_id           = data.azurerm_subnet.storage_pe_subnet.id

  private_service_connection {
    name                           = "${azurerm_storage_account.main.name}-blob"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.main.id
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = var.dns_zone_name
    private_dns_zone_ids = [var.dns_zone_id]
  }

  tags = { for k, v in var.default_tags : k => v }
}


resource "azurerm_storage_container" "private_containers" {
  depends_on = [
    azurerm_storage_account.main
  ]

  count = length(var.private_container_names)

  name                  = element(var.private_container_names, count.index)
  container_access_type = "private"
  storage_account_name  = azurerm_storage_account.main.name
}

output "name" {
  value = azurerm_storage_account.main.name
}
output "key" {
  value = azurerm_storage_account.main.primary_access_key
}
output "connection_string" {
  value = azurerm_storage_account.main.primary_connection_string
}
