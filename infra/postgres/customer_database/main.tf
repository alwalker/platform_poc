terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.14.0"
    }
  }
}

resource "random_password" "password" {
  length           = 32
  special          = true
  override_special = "!#@%*+="
  number           = true
  upper            = true
  lower            = true
}

resource "azurerm_key_vault_secret" "password" {
  name         = "${var.env}-${var.customer}-${var.app}-pg-password"
  value        = random_password.password.result
  key_vault_id = var.keyvault_id
}

resource "postgresql_role" "main" {
  name     = "${var.customer}_${var.app}"
  password = random_password.password.result

  inherit                   = true
  login                     = true
  superuser                 = false
  create_database           = false
  create_role               = false
  replication               = false
  bypass_row_level_security = false
  connection_limit          = -1
  encrypted_password        = true
}

resource "postgresql_database" "main" {
  name  = "${var.customer}_${var.app}"
  owner = postgresql_role.main.name

  tablespace_name   = "DEFAULT"
  connection_limit  = -1
  allow_connections = true
  is_template       = false
  template          = "template0"
  encoding          = "UTF8"
  lc_collate        = "DEFAULT"
  lc_ctype          = "DEFAULT"

  lifecycle {
    ignore_changes = [
      tablespace_name,
      lc_collate,
      lc_ctype
    ]
  }
}
