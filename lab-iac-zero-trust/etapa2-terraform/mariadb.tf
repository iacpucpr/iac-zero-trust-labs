
# ----- MariaDB -----
resource "docker_image" "mariadb" {
  name = "mariadb:10.11"
}

resource "docker_container" "mariadb" {
  name  = "${var.project_name}-mariadb"
  image = docker_image.mariadb.name

  restart = "unless-stopped"

  env = [
    "MYSQL_ROOT_PASSWORD=secret",
    "MYSQL_DATABASE=glpidb",
    "MYSQL_USER=glpi",
    "MYSQL_PASSWORD=glpipass"
  ]

volumes {
  host_path      = abspath("${path.module}/db_data") # caminho absoluto
  container_path = "/var/lib/mysql"
}
}
