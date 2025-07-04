# Expõe informações para o módulo raiz usar
output "network_name" {
  value = docker_network.zt_network.name
}

output "glpi_container_name" {
  value = docker_container.glpi.name
}

output "glpi_container_ip" {
  value = docker_container.glpi.network_data[0].ip_address
}

output "mariadb_container_name" {
  value = docker_container.mariadb.name
}