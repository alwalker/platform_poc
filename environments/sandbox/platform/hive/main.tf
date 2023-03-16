provider "azurerm" {
  features {}
  skip_provider_registration = true
}
provider "kubernetes" {
  config_path = "~/.kube/config"
}

data "azurerm_postgresql_server" "main" {
  name                = lower("${var.env}")
  resource_group_name = var.resource_group_name
}
data "azurerm_storage_account" "main" {
  name                = lower("${var.env}${var.customer}hive")
  resource_group_name = var.resource_group_name
}
data "azurerm_key_vault" "main" {
  name                = "${var.env}-${var.customer}"
  resource_group_name = var.resource_group_name
}
data "azurerm_key_vault_secret" "storage_account_key" {
  name         = "${var.env}-${var.customer}-storage-account-key-1"
  key_vault_id = data.azurerm_key_vault.main.id
}
data "azurerm_key_vault_secret" "hive-db-password" {
  name         = "${var.env}-${var.customer}-hive-pg-password"
  key_vault_id = data.azurerm_key_vault.main.id
}
data "azurerm_key_vault_secret" "hive-ssl-password" {
  name         = "hivesslpassword"
  key_vault_id = data.azurerm_key_vault.main.id
}
data "azurerm_key_vault_secret" "hive-ssl-keystore" {
  name         = "hivejks"
  key_vault_id = data.azurerm_key_vault.main.id
}
data "template_file" "metastore-site-xml" {
  template = file("conf/metastore-site.tpl")
  vars = {
    db_username               = "${var.customer}_hive@${split(".", data.azurerm_postgresql_server.main.fqdn)[0]}"
    db_password               = data.azurerm_key_vault_secret.hive-db-password.value
    db_name                   = "hive"
    metastore_ssl_keypassword = data.azurerm_key_vault_secret.hive-ssl-password.value
    hive_database_name        = data.azurerm_postgresql_server.main.fqdn
    thrift_port               = var.thrift_port
  }
}
data "template_file" "core-site-xml" {
  template = file("conf/core-site.tpl")
  vars = {
    storage_account_url = data.azurerm_storage_account.main.name
    storage_container   = "hive-data"
    storage_account_key = data.azurerm_key_vault_secret.storage_account_key.value
  }
}
data "template_file" "hive-site-xml" {
  template = file("conf/hive-site.tpl")
  vars = {
    db_username        = "${var.customer}_hive@${split(".", data.azurerm_postgresql_server.main.fqdn)[0]}"
    db_password        = data.azurerm_key_vault_secret.hive-db-password.value
    db_name            = "hive"
    hive_database_name = data.azurerm_postgresql_server.main.fqdn
    thrift_port        = var.thrift_port
  }
}

module "hive-kubernetes" {
  source = "../../../../apps/hive/kubernetes"

  namespace = "sandbox" #TODO CHANGE THIS TO BE PULLED FROM STATE FILE FOR CUSTOMER INFRA
  name      = "primary"

  config_files = {
    "hive-log4j2.properties" = file("conf/hive-log4j2.properties")
    "core-site.xml"          = data.template_file.core-site-xml.rendered
    "hive-site.xml"          = data.template_file.hive-site-xml.rendered
    "metastore-site.xml"     = data.template_file.metastore-site-xml.rendered
  }

  binary_config_files = {
    "acme.jks" = data.azurerm_key_vault_secret.hive-ssl-keystore.value
  }

  hive_version               = "3.1.2"
  container_tag              = "3.1.2"
  cpu_limit                  = "2"
  memory_limit               = "4Gi"
  cpu_request                = "1"
  memory_request             = "1Gi"
  thrift_port                = var.thrift_port
  healthcheck_delay_seconds  = 120
  healthcheck_period_seconds = 10
}

output "thrift_connection_string" {
  value = module.hive-kubernetes.thrift_connection_string
}
