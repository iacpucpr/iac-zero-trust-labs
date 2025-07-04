# Declara a dependência explícita do provider Docker para este módulo.
# Corrige o erro "Failed to query available provider packages".
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

# Declaração dos volumes necessários para o Authentik e Traefik.
# Corrige o erro "Reference to undeclared resource".
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

# Define o contêiner do Traefik, nosso proxy reverso e ponto de entrada.
resource "docker_container" "traefik" {
  name  = "traefik-proxy"
  image = "traefik:v2.9"

  command = [
    # Habilita o dashboard para debug (inseguro, apenas para lab)
    "--api.insecure=true",
    # Habilita o "Docker Provider" para descobrir contêineres automaticamente
    "--providers.docker=true",
    # Não expõe contêineres por padrão, apenas os que têm o label "traefik.enable=true"
    "--providers.docker.exposedbydefault=false",
    # Define os pontos de entrada para tráfego HTTP e HTTPS
    "--entrypoints.web.address=:80",
    "--entrypoints.websecure.address=:443",
    # Configura um resolvedor de certificados para gerar TLS auto-assinado
    "--certificatesresolvers.myresolver.acme.tlschallenge=true",
    "--certificatesresolvers.myresolver.acme.email=test@local.com",
    "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json",
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
    # Mapeia a porta do dashboard para 8081 para não conflitar com outros serviços
    internal = 8080
    external = 8081
  }

  volumes {
    # Permite que o Traefik escute eventos do Docker (essencial para descoberta)
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }
  volumes {
    # Volume para persistir os certificados TLS gerados
    volume_name    = docker_volume.traefik_data.name
    container_path = "/letsencrypt"
  }

  networks_advanced {
    name = var.network_name
  }
}

# Define o contêiner do Authentik, nosso Provedor de Identidade.
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
    volume_name    = docker_volume.authentik_db.name
    container_path = "/database"
  }
  volumes {
    volume_name    = docker_volume.authentik_media.name
    container_path = "/media"
  }
  volumes {
    volume_name    = docker_volume.authentik_certs.name
    container_path = "/certs"
  }

  # Configuração de ambiente robusta para garantir a comunicação interna.
  # Corrige o erro "PostgreSQL connection failed".
  env = [
    "AUTHENTIK_SECRET_KEY=supersecretkey-change-me-please",
    "AUTHENTIK_ERROR_REPORTING__ENABLED=true",
    # Variáveis explícitas para os serviços internos (PostgreSQL e Redis)
    "AUTHENTIK_POSTGRESQL__HOST=postgresql",
    "AUTHENTIK_POSTGRESQL__USER=authentik",
    "AUTHENTIK_POSTGRESQL__PASSWORD=supersecretpassword-change-me-please",
    "AUTHENTIK_POSTGRESQL__NAME=authentik",
    "AUTHENTIK_REDIS__HOST=redis"
  ]
}