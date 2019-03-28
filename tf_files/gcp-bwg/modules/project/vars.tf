variable "project_name" {}
variable "billing_account" {}
variable "folder_id" {}
variable "region" {}

variable "enable_apis" {
  description = "Whether to actually enable the APIs. If false, this module is a no-op."
  default     = "true"
}
variable "activate_apis" {
  description = "The list of apis to activate within the project"
  type        = "list"
}
variable "disable_services_on_destroy" {
  description = "Whether project services will be disabled when the resources are destroyed. https://www.terraform.io/docs/providers/google/r/google_project_service.html#disable_on_destroy"
  default     = "true"
  type        = "string"
}
