variable "traefik_port_http" {
  description = "HTTP port for Traefik"
  type        = number
  default     = 80
}

variable "traefik_port_https" {
  description = "HTTPS port for Traefik"
  type        = number
  default     = 443
}

variable "traefik_port_dashboard" {
  description = "Dashboard port for Traefik"
  type        = number
  default     = 8080
}

variable "domain" {
  description = "Base domain for services"
  type        = string
  default     = "7f000001.nip.io"
}

