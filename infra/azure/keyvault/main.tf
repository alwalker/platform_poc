data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                        = "${var.env}-${var.customer}"
  location                    = var.azure_region
  resource_group_name         = var.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = var.retention_in_days
  purge_protection_enabled    = var.purge_protection_enabled
  enable_rbac_authorization   = var.enable_rbac_authorization

  sku_name = var.sku_name

  dynamic "access_policy" {
    for_each = var.access_policies

    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = access_policy.value["object_id"]

      secret_permissions      = access_policy.value["secret_permissions"]
      key_permissions         = access_policy.value["key_permissions"]
      storage_permissions     = access_policy.value["storage_permissions"]
      certificate_permissions = access_policy.value["certificate_permissions"]
    }
  }

  tags = { for k, v in var.default_tags : k => v }
}

data "azurerm_subnet" "kv_pe_subnet" {
  name                 = var.pe_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}
resource "azurerm_private_endpoint" "main" {
  name                = "${azurerm_key_vault.main.name}-kv"
  resource_group_name = var.resource_group_name
  location            = var.azure_region
  subnet_id           = data.azurerm_subnet.kv_pe_subnet.id

  private_service_connection {
    name                           = azurerm_key_vault.main.name
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = var.dns_zone_name
    private_dns_zone_ids = [var.dns_zone_id]
  }

  tags = { for k, v in var.default_tags : k => v }
}
