terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

resource "docker_volume" "authentik_db" {
  name = "authentik_db_vol"
}
resource "docker_volume" "authentik_media" {
  name = "authentik_media_vol"
}
resource "docker_volume" "authentik_certs" {
  name = "authentik_certs_vol"
}
resource "docker_volume" "traefik_data" {
  name = "traefik_data_vol"
}

resource "docker_container" "traefik" {
  name  = "traefik-proxy"
  image = "traefik:v2.9"
  command = [
    "--api.insecure=true",
    "--providers.docker=true",
    "--providers.docker.exposedbydefault=false",
    "--entrypoints.web.address=:80",
    "--entrypoints.websecure.address=:443",
    "--certificatesresolvers.myresolver.acme.tlschallenge=true",
    "--certificatesresolvers.myresolver.acme.email=test@local.com",
    "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json",
    "--log.level=DEBUG"
  ]
  ports {
    internal = 80
    external = 80
  }
  ports {
    internal = 443
    external = 443
  }
  ports {
    internal = 8080
    external = 8081 # Usando 8081 para não conflitar com o baseline
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }
  volumes {
    volume_name    = docker_volume.traefik_data.name
    container_path = "/letsencrypt"
  }
  networks_advanced {
    name = var.network_name
  }
}

resource "docker_container" "authentik" {
  name    = "authentik-idp"
  image   = "ghcr.io/goauthentik/server:latest"
  restart = "always"
  ports {
    internal = 9000
    external = 9000
  }
  ports {
    internal = 9443
    external = 9443
  }
  networks_advanced {
    name = var.network_name
  }
  volumes {
    volume_name = docker_volume.authentik_db.name
    container_path = "/database"
  }
  volumes {
    volume_name = docker_volume.authentik_media.name
    container_path = "/media"
  }
  volumes {
    volume_name = docker_volume.authentik_certs.name
    container_path = "/certs"
  }
  env = [
    "AUTHENTIK_SECRET_KEY=supersecretkey-change-me",
    "AUTHENTIK_ERROR_REPORTING__ENABLED=true"
  ]
}
