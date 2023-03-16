data "azurerm_key_vault" "main" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name
}

data "azurerm_key_vault_secret" "certificate" {
  name         = "wildcardcer"
  key_vault_id = data.azurerm_key_vault.main.id
}
data "azurerm_key_vault_secret" "key" {
  name         = "wildcardkey"
  key_vault_id = data.azurerm_key_vault.main.id
}
data "azurerm_key_vault_secret" "mapbox-api-key" {
  name         = "MAPBOXAPIKEY"
  key_vault_id = data.azurerm_key_vault.main.id
}

resource "kubernetes_secret" "wildcard-ssl" {
  metadata {
    name      = "wildcard-ssl"
    namespace = var.namespace
  }

  binary_data = {
    "tls.crt" = data.azurerm_key_vault_secret.certificate.value
    "tls.key" = data.azurerm_key_vault_secret.key.value
  }
}
resource "kubernetes_secret" "mapbox-api-key" {
  metadata {
    name      = "mapbox-api-key"
    namespace = var.namespace
  }

  data = {
    "mapbox-api-key" = data.azurerm_key_vault_secret.mapbox-api-key.value
  }
}
