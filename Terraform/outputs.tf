output "postgresql_server_fqdn" {
  value = azurerm_postgresql_flexible_server.pgsql_server.fqdn
}

output "postgresql_databases" {
  value = azurerm_postgresql_flexible_server_database.pgsql_db[*].name
}

output "key_vault_uri" {
  value = azurerm_key_vault.keyvault.vault_uri
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "static_web_app_url" {
  value = azurerm_static_web_app.vue_frontend.default_host_name
}