variable "network_name" {
  description = "Nome da rede Docker para conectar os contêineres."
  type        = string
}

variable "twingate_access_token" {
  description = "Access token do conector Twingate."
  type        = string
  sensitive   = true
}

variable "twingate_refresh_token" {
  description = "Refresh token do conector Twingate."
  type        = string
  sensitive   = true
}

variable "twingate_network" {
  description = "Nome da sua rede no Twingate."
  type        = string
}