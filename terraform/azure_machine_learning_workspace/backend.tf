locals {
  st_acc_name = "stdstfstate${var.azure_sub_name}"
  ct_name        = "ctdstfstate${var.azure_sub_name}"
}

terraform {
  backend "azurerm" {
    resource_group_name     = "rg-terraform-infrastructure"
    storage_account_name    = local.st_acc_name
    container_name          = local.ct_name
    key                     = "terraform.tfstate"

  }
}
