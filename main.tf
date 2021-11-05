terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

provider "azurerm" {
    subscription_id = var.provider_login.subscription_id
    tenant_id =  var.provider_login.tenant_id
    client_id =  var.provider_login.client_id
    client_secret =  var.provider_login.client_secret
    
  features {
    
  }
}

data "azurerm_resource_group" "backend_app_rg"{
  name = "backend_app"
}

# Create the Linux App Service Plan
resource "azurerm_app_service_plan" "service_plan" {
  name                = "${var.name}-service-plan"
  location            = data.azurerm_resource_group.backend_app_rg.location
  resource_group_name = data.azurerm_resource_group.backend_app_rg.name
  sku {
    tier = "Free"
    size = "F1"
  }
   tags = {
    environment = "${var.environment}"
  }
}

# Create the web app, pass in the App Service Plan ID, and deploy code from a public GitHub repo
resource "azurerm_app_service" "sales_module" {
  name                = "${var.name}-sales-service"
  location            = data.azurerm_resource_group.backend_app_rg.location
  resource_group_name = data.azurerm_resource_group.backend_app_rg.name
  app_service_plan_id = azurerm_app_service_plan.service_plan.id

   tags = {
    environment = "${var.environment}"
  }

   connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${var.name}-database-server1.database.windows.net;Initial Catalog=${azurerm_sql_database.database.name};Persist Security Info=False;User ID=${var.sql_server_login.username};Password=${var.sql_server_login.password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=60;"
  }
}


resource "azurerm_app_service" "identity" {
  name                = "${var.name}-identity-service"
  location            =  data.azurerm_resource_group.backend_app_rg.location
  resource_group_name = data.azurerm_resource_group.backend_app_rg.name
  app_service_plan_id = azurerm_app_service_plan.service_plan.id

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=tcp:${var.name}-database-server1.database.windows.net;Initial Catalog=${azurerm_sql_database.database.name};Persist Security Info=False;User ID=${var.sql_server_login.username};Password=${var.sql_server_login.password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=60;"
  }
}

resource "azurerm_sql_server" "sql_server" {
  name                         = "${var.name}-database-server1"
  resource_group_name          = data.azurerm_resource_group.backend_app_rg.name
  location                     = data.azurerm_resource_group.backend_app_rg.location
  version                      = "12.0"
  administrator_login          = var.sql_server_login.username
  administrator_login_password = var.sql_server_login.password

   tags = {
    environment = "${var.environment}"
  }
}

resource "azurerm_sql_firewall_rule" "firewall_rule_3" {
  name                = "${var.name}-firewall-rule-3"
  resource_group_name = data.azurerm_resource_group.backend_app_rg.name
  server_name         = azurerm_sql_server.sql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
  # every ip
}

resource "azurerm_sql_database" "database" {
  name                = "${var.name}-database"
  resource_group_name = data.azurerm_resource_group.backend_app_rg.name
  location            = data.azurerm_resource_group.backend_app_rg.location
  server_name         = azurerm_sql_server.sql_server.name
  # environment         = "production"
  edition             = "Basic"
  max_size_bytes      = "2147483648"
  requested_service_objective_id = "dd6d99bb-f193-4ec1-86f2-43d3bccbc49c"
  requested_service_objective_name = "Basic"

   tags = {
    environment = "${var.environment}"
  }
}

