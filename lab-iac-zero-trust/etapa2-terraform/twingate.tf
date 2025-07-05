
# ----- Twingate Connector (optional) -----
resource "docker_image" "twingate_connector" {
  count = var.twingate_connector_token == "" ? 0 : 1
  name  = "twingate/connector:latest"
}

resource "docker_container" "twingate_connector" {
  count = var.twingate_connector_token == "" ? 0 : 1
  name  = "${var.project_name}-twingate-connector"
  image = docker_image.twingate_connector[0].name

  env = [
    "TWINGATE_ACCESS_TOKEN=${var.twingate_connector_token}"
  ]
  restart = "unless-stopped"
}
