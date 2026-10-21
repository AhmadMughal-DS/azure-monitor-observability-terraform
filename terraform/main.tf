locals {
  name_prefix = var.project_name
}

module "monitoring" {
  source      = "./modules/monitoring"
  name_prefix = local.name_prefix
  location    = var.location
  environment = var.environment
  alert_email = var.alert_email
}
