resource "azurerm_static_web_app" "vue_frontend" {
  name                = var.static_web_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = "East Asia"
  sku_tier            = "Free"

  # app_settings 블록을 사용하여 앱 설정을 지정합니다.
  app_settings = {
    APP_LOCATION    = "/"
    OUTPUT_LOCATION = "dist"
  }

 
}

