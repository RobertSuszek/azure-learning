terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "random_password" "password" {
  length  = 16
  special = true
}

data "azuread_domains" "aad_domain" {}

resource "azuread_user" "user" {
  user_principal_name   = "az104-user1@${data.azuread_domains.aad_domain.domains.0.domain_name}"
  display_name          = "az104-user1"
  account_enabled       = true
  job_title             = "IT Lab Administrator"
  department            = "IT"
  usage_location        = "PL"
  password              = random_password.password.result
  force_password_change = true

}

resource "azuread_group" "static_group" {
  display_name     = "IT Lab Administrators Static"
  description      = "Administrators that manage the IT lab"
  security_enabled = true
  members          = [azuread_user.user.id]
}

resource "azuread_group" "dynamic_group" {
  display_name     = "IT Lab Administrators Dynamic"
  description      = "Administrators that manage the IT lab"
  security_enabled = true
  types            = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "(user.jobTitle -eq \"IT Lab Administrator\")"
  }
}