resource "azurerm_resource_group" "this" {
  name     = "${var.name_prefix}-rg"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.name_prefix}-law"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "this" {
  name                = "${var.name_prefix}-ai"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
}

resource "azurerm_monitor_action_group" "this" {
  name                = "${var.name_prefix}-ag"
  resource_group_name = azurerm_resource_group.this.name
  short_name          = "ahmadag"

  email_receiver {
    name          = "ops"
    email_address = var.alert_email
  }
}

############################
# Log-based alert
############################
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "exceptions" {
  name                = "${var.name_prefix}-exceptions-alert"
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
}

############################
# Metric alert (failed requests)
############################
resource "azurerm_monitor_metric_alert" "failed_requests" {
  name                = "${var.name_prefix}-failed-requests"
  resource_group_name = azurerm_resource_group.this.name
  scopes              = [azurerm_application_insights.this.id]
  description         = "Alert when failed requests exceed threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "requests/failed"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = 5
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}
