
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
variable "twingate_login" {
  description = "Twingate Login NAME.twingate.com"
  type = string
  default  = "iacpucpr"
}
variable "twingate_api-token" {
  description = "Twingate API-TOKEN provided by twingate"
  type = string
  default  = "TOKEN"
}
