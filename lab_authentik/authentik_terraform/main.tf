terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "docker" {}

# Gerar senhas aleatórias
resource "random_password" "pg_pass" {
  length  = 36
  special = true
}

resource "random_password" "authentik_secret_key" {
  length  = 60
  special = true
}

# Criar networks
resource "docker_network" "authentik_network" {
  name = "authentik_network"
}

# Criar volumes
resource "docker_volume" "database" {
  name = "authentik_database"
}

resource "docker_volume" "redis" {
  name = "authentik_redis"
}

# PostgreSQL Container
resource "docker_image" "postgres" {
  name = "postgres:16-alpine"
}

resource "docker_container" "postgresql" {
  name  = "authentik_postgresql"
  image = docker_image.postgres.image_id

  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.authentik_network.name
  }

  volumes {
    # Only specify host_path and container_path for a bind mount
    host_path      = "${path.cwd}/data/postgresql"
    container_path = "/var/lib/postgresql/data"
  }

  env = [
    "POSTGRES_PASSWORD=${var.pg_password}",
    "POSTGRES_USER=${var.pg_user}",
    "POSTGRES_DB=${var.pg_db}",
  ]

  healthcheck {
    test     = ["CMD-SHELL", "pg_isready -d $${POSTGRES_DB} -U $${POSTGRES_USER}"]
    interval = "30s"
    timeout  = "5s"
    retries  = 5
  }
}

# Redis Container
resource "docker_image" "redis" {
  name = "redis:alpine"
}

resource "docker_container" "redis" {
  name  = "authentik_redis"
  image = docker_image.redis.image_id
  
  restart = "unless-stopped"
  command = ["--save", "60", "1", "--loglevel", "warning"]
  
  networks_advanced {
    name = docker_network.authentik_network.name
  }
  
  volumes {
    volume_name    = docker_volume.redis.name
    container_path = "/data/redis"
  }
  
  healthcheck {
    test     = ["CMD-SHELL", "redis-cli ping | grep PONG"]
    interval = "30s"
    timeout  = "3s"
    retries  = 5
  }
}

# Authentik Server Container
resource "docker_image" "authentik" {
  name = "${var.authentik_image}:${var.authentik_tag}"
}

resource "docker_container" "authentik_server" {
  name  = "authentik_server"
  image = docker_image.authentik.image_id
  
  restart = "unless-stopped"
  command = ["server"]
  
  networks_advanced {
    name = docker_network.authentik_network.name
  }
  
  ports {
    internal = 9000
    external = var.compose_port_http
  }
  
  ports {
    internal = 9443
    external = var.compose_port_https
  }
  
  volumes {
    host_path      = "${path.cwd}/media"
    container_path = "/media"
  }
  
  volumes {
    host_path      = "${path.cwd}/custom-templates"
    container_path = "/templates"
  }
  
  env = [
    "AUTHENTIK_SECRET_KEY=${random_password.authentik_secret_key.result}",
    "AUTHENTIK_REDIS__HOST=authentik_redis",
    "AUTHENTIK_POSTGRESQL__HOST=authentik_postgresql",
    "AUTHENTIK_POSTGRESQL__USER=${var.pg_user}",
    "AUTHENTIK_POSTGRESQL__NAME=${var.pg_db}",
    "AUTHENTIK_POSTGRESQL__PASSWORD=${var.pg_password}",
    "AUTHENTIK_ERROR_REPORTING__ENABLED=${var.authentik_error_reporting_enabled}",
  ]
  
  depends_on = [
    docker_container.postgresql,
    docker_container.redis
  ]
}

# Authentik Worker Container
resource "docker_container" "authentik_worker" {
  name  = "authentik_worker"
  image = docker_image.authentik.image_id
  
  restart = "unless-stopped"
  command = ["worker"]
  user    = "root"
  
  networks_advanced {
    name = docker_network.authentik_network.name
  }
  
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
  
  volumes {
    host_path      = "${path.cwd}/media"
    container_path = "/media"
  }
  
  volumes {
    host_path      = "${path.cwd}/certs"
    container_path = "/certs"
  }
  
  volumes {
    host_path      = "${path.cwd}/custom-templates"
    container_path = "/templates"
  }
  env = [
    "AUTHENTIK_SECRET_KEY=${random_password.authentik_secret_key.result}",
    "AUTHENTIK_REDIS__HOST=authentik_redis",
    "AUTHENTIK_POSTGRESQL__HOST=authentik_postgresql",
    "AUTHENTIK_POSTGRESQL__USER=${var.pg_user}",
    "AUTHENTIK_POSTGRESQL__NAME=${var.pg_db}",
    "AUTHENTIK_POSTGRESQL__PASSWORD=${var.pg_password}",
    "AUTHENTIK_ERROR_REPORTING__ENABLED=${var.authentik_error_reporting_enabled}",
  ]
  
  depends_on = [
    docker_container.postgresql,
    docker_container.redis
  ]
}

# Criar diretórios locais
resource "null_resource" "create_directories" {
  provisioner "local-exec" {
    command = "mkdir -p data/postgresql data/redis media custom-templates certs"
  }
  
  triggers = {
    always_run = timestamp()
  }
}

