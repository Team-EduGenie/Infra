variable "location" {}
variable "resource_group_name" {}
variable "vnet_name" {}
variable "appgw_subnet_name" {}
variable "aks_subnet_name" {}
variable "application_gateway_name" {}
variable "public_ip_name" {}
variable "aks_cluster_name" {}
variable "acr_name" {}
variable "postgresql_server_name" {}
variable "postgresql_admin_username" {}
variable "postgresql_admin_password" {}
variable "postgresql_databases" { type = list(string) }
variable "key_vault_name" {}
variable "static_website_storage_name" { type = string }
variable "static_web_fqdn" {}
variable "aks_ingress_pip" {}
variable "static_web_app_name" { type = string }
variable "github_repo_url" { type = string }
variable "github_branch" { type    = string }
variable "github_token" {}
variable "keyvault_cert_secret_id" {}