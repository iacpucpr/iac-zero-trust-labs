variable "pg_user" {
  description = "PostgreSQL user"
  type        = string
  default     = "authentik"
}

variable "pg_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "authentik"
}

variable "authentik_image" {
  description = "Authentik Docker image"
  type        = string
  default     = "ghcr.io/goauthentik/server"
}

variable "authentik_tag" {
  description = "Authentik Docker image tag"
  type        = string
  default     = "2025.6.3"
}

variable "compose_port_http" {
  description = "HTTP port for Authentik"
  type        = number
  default     = 9000
}

variable "compose_port_https" {
  description = "HTTPS port for Authentik"
  type        = number
  default     = 9443
}

variable "authentik_error_reporting_enabled" {
  description = "Enable error reporting for Authentik"
  type        = string
  default     = "true"
}
variable "pg_password" {
  description = "A senha para o usuário PostgreSQL (authentik)."
  type        = string
  sensitive   = true # Marca como sensível para não aparecer em logs
}
