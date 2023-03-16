terraform {  
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.14.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

module "keyvault" {
  source = "../../../../infra/azure/keyvault"

  azure_region              = var.azure_region
  resource_group_name       = var.resource_group_name
  customer                  = replace(var.customer, "/[^a-zA-Z0-9]/", "")
  env                       = replace(var.env, "/[^a-zA-Z0-9]/", "")
  enable_rbac_authorization = true

  pe_subnet_name = "Keyvault_PEs"
  vnet_name      = var.vnet_name
  dns_zone_id    = var.storage_private_dns_zone_id
  dns_zone_name  = var.storage_private_dns_zone_name

  default_tags = merge(
    var.default_customer_tags,
    var.default_env_tags,
  { terraform = true })
}

module "hive_storage_account" {
  source = "../../../../infra/azure/storage_account"

  azure_region        = var.azure_region
  resource_group_name = var.resource_group_name
  customer            = var.customer
  env                 = replace(var.env, "/[^a-zA-Z0-9]/", "")
  purpose             = "hive"

  keyvault_id = module.keyvault.keyvault_id

  private_container_names = ["hive-data"]

  pe_subnet_name = "Storage_PEs"
  vnet_name      = var.vnet_name
  dns_zone_id    = var.storage_private_dns_zone_id
  dns_zone_name  = var.storage_private_dns_zone_name

  default_tags = merge(
    var.default_customer_tags,
    var.default_env_tags,
  { terraform = true })
}

data "azurerm_postgresql_server" "main" {
  name                = lower("${var.env}")
  resource_group_name = var.resource_group_name
}
data "azurerm_private_endpoint_connection" "database" {
  name                = "${lower("${var.env}")}-psql"
  resource_group_name = var.resource_group_name
}
data "azurerm_key_vault_secret" "database_admin_password" {
  name         = "${var.env}-pg-admin-password"
  key_vault_id = var.global_keyvault_id
}
provider "postgresql" {
  host              = data.azurerm_private_endpoint_connection.database.private_service_connection[0].private_ip_address
  port              = 5432
  database          = "postgres"
  username          = "${data.azurerm_postgresql_server.main.administrator_login}@${split(".", data.azurerm_postgresql_server.main.fqdn)[0]}"
  database_username = data.azurerm_postgresql_server.main.administrator_login
  superuser         = false
  password          = data.azurerm_key_vault_secret.database_admin_password.value
  sslmode           = "require"
  connect_timeout   = 30
}

module "hive_database" {
  source = "../../../../infra/postgres/customer_database"

  env      = var.env
  customer = var.customer
  app      = "hive"

  keyvault_id = module.keyvault.keyvault_id
}
module "superset_database" {
  source = "../../../../infra/postgres/customer_database"

  env      = var.env
  customer = var.customer
  app      = "superset"

  keyvault_id = module.keyvault.keyvault_id
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "kubernetes-namespace" {
  source = "../../../../infra/kubernetes/namespace"

  namespace = var.env
}

module "kubernetes-secrets" {
  source = "../../../../infra/kubernetes/standard_secrets"

  depends_on = [
    module.kubernetes-namespace
  ]

  namespace           = var.env
  keyvault_name       = "acme-global"
  resource_group_name = var.resource_group_name
}
