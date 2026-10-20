locals {
  name = var.project_name
  tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
    Owner     = "Muhammad Ahmad"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "${local.name}-rg"
  location = var.location
  tags     = local.tags
}

############################
# Log Analytics + App Insights
############################
resource "azurerm_log_analytics_workspace" "this" {
  name                = "${local.name}-law"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_application_insights" "this" {
  name                = "${local.name}-ai"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = local.tags
}

############################
# Action group (email)
############################
resource "azurerm_monitor_action_group" "this" {
  name                = "${local.name}-ag"
  resource_group_name = azurerm_resource_group.this.name
  short_name          = "ahmadag"

  email_receiver {
    name          = "ops"
    email_address = var.alert_email
  }

  tags = local.tags
}

############################
# Log-based alert: exceptions
############################
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "exceptions" {
  name                = "${local.name}-exceptions-alert"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  scopes               = [azurerm_log_analytics_workspace.this.id]
  severity             = 2

  criteria {
    query                   = <<-QUERY
      AppExceptions
      | summarize Count = count()
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.this.id]
  }

  tags = local.tags
}
