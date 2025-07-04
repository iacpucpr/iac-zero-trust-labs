terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

# Cria a rede, que será usada por todos
resource "docker_network" "zt_network" {
  name = var.network_name
}

# Volume e Contêiner do Banco de Dados
resource "docker_volume" "mariadb_data" {
  name = "mariadb_data_vol"
}

resource "docker_container" "mariadb" {
  name    = "mariadb-server"
  image   = "mariadb:10.5"
  restart = "always"
  networks_advanced {
    name = docker_network.zt_network.name
  }
  volumes {
    volume_name    = docker_volume.mariadb_data.name
    container_path = "/var/lib/mysql"
  }
  env = [
    "MYSQL_ROOT_PASSWORD=supersecretpassword",
    "MYSQL_DATABASE=glpidb",
    "MYSQL_USER=glpiuser",
    "MYSQL_PASSWORD=glpipassword",
    "MYSQL_AUTHENTICATION_PLUGIN=mysql_native_password"
  ]
}

# Volume e Contêiner do GLPI
resource "docker_volume" "glpi_data" {
  name = "glpi_data_vol"
}

resource "docker_container" "glpi" {
  name       = "glpi-app"
  image      = "diouxx/glpi:latest"
  restart    = "always"
  depends_on = [docker_container.mariadb]

  networks_advanced {
    name = docker_network.zt_network.name
  }

  volumes {
    volume_name    = docker_volume.glpi_data.name
    container_path = "/var/www/html/glpi"
  }

  env = [
    "DB_HOST=mariadb-server",
    "DB_USER=glpiuser",
    "DB_PASSWORD=glpipassword",
    "DB_NAME=glpidb"
  ]
  
  # A lógica de porta e labels agora é controlada por variáveis de entrada
 dynamic "labels" {
    for_each = var.glpi_labels
    content {
      label = labels.key
      value = labels.value
    }
  }
}