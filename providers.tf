# terraform {

#   required_version = ">=0.12"

#   required_providers {
#     azurerm = {
#       source  = "hashicorp/azurerm"
#       version = "~>2.0"
#     }
#   }
# }

provider "azurerm" {
  features {}
  subscription_id = "7fcfbbab-6c02-4dc7-99d4-0ad01473636c"
  tenant_id       = "b0fb9891-78ad-46b4-98ad-6b22271c7ae3"
  client_id       = "b6fa71fb-a72e-4229-aa2b-93d51a275529"
  client_secret   = "oGC8Q~HqJJRepp3HRvTCWdV6ASTBvVQrP405nbbT"
}
