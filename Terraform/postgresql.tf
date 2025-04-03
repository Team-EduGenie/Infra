resource "azurerm_postgresql_flexible_server" "pgsql_server" {
  name                   = var.postgresql_server_name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "14"
  sku_name               = "GP_Standard_D2s_v3"
  administrator_login    = var.postgresql_admin_username
  administrator_password = var.postgresql_admin_password
  storage_mb             = 32768
  backup_retention_days  = 7
  zone                   = 1
}

resource "azurerm_postgresql_flexible_server_database" "pgsql_db" {
  count     = length(var.postgresql_databases)
  name      = var.postgresql_databases[count.index]
  server_id = azurerm_postgresql_flexible_server.pgsql_server.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}
