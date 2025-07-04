resource "docker_container" "twingate_connector" {
  name    = "twingate-connector"
  image   = "twingate/connector:latest"
  restart = "always"
  networks_advanced {
    name = var.network_name
  }
  env = [
    "TWINGATE_ACCESS_TOKEN=${var.twingate_access_token}",
    "TWINGATE_REFRESH_TOKEN=${var.twingate_refresh_token}",
    "TWINGATE_NETWORK=${var.twingate_network}"
  ]
}