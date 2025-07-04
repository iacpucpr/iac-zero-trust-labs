variable "network_name" {
  description = "Nome da rede Docker a ser criada."
  type        = string
  default     = "zt_lab_net"
}

variable "publish_glpi_port" {
  description = "Se true, publica a porta 8080 do GLPI."
  type        = bool
  default     = true
}

variable "glpi_labels" {
  description = "Mapa de labels a serem aplicados ao contêiner do GLPI."
  type        = map(string)
  default     = {}
}