variable "enable_lab_a" {
  description = "Se true, ativa o módulo do Lab A (Traefik + Authentik)."
  type        = bool
  default     = false
}

variable "enable_lab_b" {
  description = "Se true, ativa o módulo do Lab B (Twingate)."
  type        = bool
  default     = false
}

variable "twingate_access_token" {
  description = "Access token do conector Twingate."
  type        = string
  sensitive   = true
  default     = "COLE_SEU_ACCESS_TOKEN_AQUI"
}

variable "twingate_refresh_token" {
  description = "Refresh token do conector Twingate."
  type        = string
  sensitive   = true
  default     = "COLE_SEU_REFRESH_TOKEN_AQUI"
}

variable "twingate_network" {
  description = "Nome da sua rede no Twingate (ex: lab-docker)."
  type        = string
  default     = "lab-docker"
}