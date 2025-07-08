
variable "project_name" {
  description = "Prefix for Docker resource names"
  type        = string
  default     = "lab-zero-trust"
}
variable "twingate_connector_token" {
  description = "Registration token for the Twingate Connector (optional)"
  type        = string
  default     = ""
}
