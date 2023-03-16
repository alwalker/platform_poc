provider "azurerm" {
  features {}
  skip_provider_registration = true
}

module "database_server" {
  source = "../../../infra/azure/database_server"

  azure_region        = var.azure_region
  env                 = var.env
  resource_group_name = var.resource_group_name

  keyvault_id = var.keyvault_id

  admin_username       = var.db_admin_name
  geo_redundant_backup = false


  pe_subnet_name = "PSQL_PEs"
  vnet_name      = var.vnet_name
  dns_zone_id    = var.pg_private_dns_zone_id
  dns_zone_name  = var.pg_private_dns_zone_name

  default_tags = merge(
    var.default_env_tags,
  { terraform = true })
}
