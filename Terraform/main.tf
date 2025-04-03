terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.80.0"
    }
  }
}


provider "azurerm" {
  features {}

  subscription_id = "dd768d51-1ac4-493d-9f54-1936e5993b50"
}
