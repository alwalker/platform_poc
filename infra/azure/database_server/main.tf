resource "random_password" "password" {
  length           = 32
  special          = true
  override_special = "!#@%*+="
  number           = true
  upper            = true
  lower            = true
}
resource "azurerm_key_vault_secret" "password" {
  name         = "${var.env}-pg-admin-password"
  value        = random_password.password.result
  key_vault_id = var.keyvault_id
}

resource "azurerm_postgresql_server" "main" {
  name                = lower("${var.env}")
  resource_group_name = var.resource_group_name
  location            = var.azure_region

  sku_name   = var.sku_name
  version    = var.engine_version
  storage_mb = var.storage_size

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup
  auto_grow_enabled            = var.auto_grow_enabled

  public_network_access_enabled    = var.public_network_access_enabled
  ssl_enforcement_enabled          = var.ssl_enforcement_enabled
  ssl_minimal_tls_version_enforced = var.ssl_minimal_tls_version_enforced

  administrator_login          = var.admin_username
  administrator_login_password = random_password.password.result

  tags = { for k, v in var.default_tags : k => v }
}


data "azurerm_subnet" "pg_pe_subnet" {
  name                 = var.pe_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}
resource "azurerm_private_endpoint" "main" {
  name                = "${azurerm_postgresql_server.main.name}-psql"
  resource_group_name = var.resource_group_name
  location            = var.azure_region
  subnet_id           = data.azurerm_subnet.pg_pe_subnet.id

  private_service_connection {
    name                           = azurerm_postgresql_server.main.name
    private_connection_resource_id = azurerm_postgresql_server.main.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = var.dns_zone_name
    private_dns_zone_ids = [var.dns_zone_id]
  }

  tags = { for k, v in var.default_tags : k => v }
}
