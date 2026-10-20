variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Name prefix applied to all resources"
  type        = string
  default     = "ahmad-monitor"
}

variable "alert_email" {
  description = "Email address for alert notifications"
  type        = string
  default     = "ops@example.com"
}
