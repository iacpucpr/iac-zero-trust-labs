
# ----- GLPI -----
resource "docker_image" "glpi" {
  name = "diouxx/glpi"
}

resource "docker_container" "glpi" {
  name  = "${var.project_name}-glpi"
  image = docker_image.glpi.name

  depends_on = [docker_container.mariadb]

  env = [
    "DB_HOST=${docker_container.mariadb.name}",
    "DB_USER=glpi",
    "DB_PASSWORD=glpipass",
    "DB_NAME=glpidb"
  ]

  ports {
    internal = 80
    external = local.glpi_port
  }

  restart = "unless-stopped"
}
