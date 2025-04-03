# key vault 접근 용도

data "azurerm_client_config" "current" {}


resource "azurerm_user_assigned_identity" "appgw_identity" {
  name                = "appgw-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_key_vault_access_policy" "appgw_kv_access" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.appgw_identity.principal_id

  secret_permissions = ["Get"]
}

# 🔍 App Gateway 서브넷
data "azurerm_subnet" "appgw_subnet" {
  name                 = var.appgw_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.resource_group_name
}

# 🌐 Public IP
resource "azurerm_public_ip" "appgw_pip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 🚪 Application Gateway
resource "azurerm_application_gateway" "appgw" {
  name                = var.application_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  probe {
    name                = "dummy-probe"
    protocol            = "Http"
    host                = "api.edugenies.com"
    path                = "/"
    interval            = 30
    timeout             = 10
    unhealthy_threshold = 3
  }
  
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appgw_identity.id]
  }

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = data.azurerm_subnet.appgw_subnet.id
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_pip.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_port {
    name = "https"
    port = 443
  }

  # 🔐 SSL 인증서 설정 (예: Key Vault 인증서 ID 사용)
  ssl_certificate {
    name     = "ssl-cert"
    key_vault_secret_id = var.keyvault_cert_secret_id
  }

  # ✅ 백엔드: AKS Ingress
  backend_address_pool {
    name  = "aks-backend-pool"
    ip_addresses = [var.aks_ingress_pip]
  }

  backend_http_settings {
    name                                = "aks-http-settings"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 20
    pick_host_name_from_backend_address = false
    host_name                           = "api.edugenies.com"
    cookie_based_affinity               = "Disabled"
    probe_name                          = "dummy-probe"
  }

  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "https"
    protocol                       = "Https"
    ssl_certificate_name           = "ssl-cert"
    host_name                      = "api.edugenies.com" 
    require_sni                    = true                
  }

  request_routing_rule {
    name               = "api-routing-rule"
    rule_type          = "Basic"
    http_listener_name = "https-listener"
    backend_address_pool_name  = "aks-backend-pool"
    backend_http_settings_name = "aks-http-settings"
    priority           = 100
  }

  #  HTTP → HTTPS 리디렉션
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  redirect_configuration {
    name = "redirect-to-https"
    redirect_type = "Permanent"
    target_listener_name = "https-listener"
    include_path = true
    include_query_string = true
  }

  request_routing_rule {
    name               = "http-to-https"
    rule_type          = "Basic"
    http_listener_name = "http-listener"
    redirect_configuration_name = "redirect-to-https"
    priority           = 10
  }

  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
}



