output "log_analytics_workspace_id" {
  value = module.monitoring.log_analytics_workspace_id
}
output "app_insights_connection_string" {
  value     = module.monitoring.app_insights_connection_string
  sensitive = true
}
output "action_group_id" {
  value = module.monitoring.action_group_id
}
