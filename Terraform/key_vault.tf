resource "azurerm_key_vault" "keyvault" {
  name                       = var.key_vault_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = azurerm_kubernetes_cluster.aks.identity[0].tenant_id
  sku_name                   = "standard"



  access_policy {
    tenant_id = azurerm_kubernetes_cluster.aks.identity[0].tenant_id
    object_id = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id

    secret_permissions = ["Get", "List"]
  }


}
