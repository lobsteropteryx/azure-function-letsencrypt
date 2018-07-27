variable "subscription_id" {}
variable "tenant_id" {}
variable "client_id" {}
variable "client_secret" {}

provider "azurerm" {

}

resource "azurerm_resource_group" "test" {
  name     = "azure-functions-ssl-test"
  location = "centralus"
}

resource "azurerm_storage_account" "test" {
  name                     = "azurefunctionsssltest"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  location                 = "${azurerm_resource_group.test.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_application_insights" "test" {
  name                = "azure-functions-ssl-test"
  location            = "South Central US"
  resource_group_name = "${azurerm_resource_group.test.name}"
  application_type    = "Web"
}

resource "azurerm_app_service_plan" "test" {
  name                = "azure-functions-ssl-test"
  location            = "${azurerm_resource_group.test.location}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "test" {
  name                      = "azure-functions-ssl-test"
  location                  = "${azurerm_resource_group.test.location}"
  resource_group_name       = "${azurerm_resource_group.test.name}"
  app_service_plan_id       = "${azurerm_app_service_plan.test.id}"
  storage_connection_string = "${azurerm_storage_account.test.primary_connection_string}"
  https_only = false

  app_settings {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.test.instrumentation_key}"
    "letsencrypt:SubscriptionId" = "${var.subscription_id}"
    "letsencrypt:Tenant" = "${var.tenant_id}"
    "letsencrypt:ClientId" = "${var.client_id}"
    "letsencrypt:ClientSecret" = "${var.client_secret}"
    "letsencrypt:ResourceGroupName" = "${azurerm_resource_group.test.name}"
    "letsencrypt:ServicePlanResourceGroupName" = "${azurerm_resource_group.test.name}"
    "letsencrypt:UseIPBasedSSL" = false
  }
}
