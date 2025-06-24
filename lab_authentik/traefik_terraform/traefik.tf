terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# Criar diretórios necessários
resource "null_resource" "create_traefik_directories" {
  provisioner "local-exec" {
    command = "mkdir -p certs config"
  }
  
  triggers = {
    always_run = timestamp()
  }
}

# Criar arquivo de configuração dinâmica do Traefik
resource "local_file" "traefik_dynamic_config" {
  depends_on = [null_resource.create_traefik_directories]
  
  content = yamlencode({
    tls = {
      certificates = [
        {
          certFile = "/certs/traefik.crt"
          keyFile  = "/certs/traefik.key"
        }
      ]
    }
  })
  
  filename = "${path.cwd}/config/dynamic.yml"
}

# Criar rede para Traefik
resource "docker_network" "traefik_network" {
  name = "traefik_network"
}

# Traefik Container
resource "docker_image" "traefik" {
  name = "traefik:v3.4"
}

resource "docker_container" "traefik" {
  name  = "traefik"
  image = docker_image.traefik.image_id
  
  restart = "unless-stopped"
  
  command = [
    "--api.insecure=true",
    "--providers.docker=true",
    "--providers.docker.exposedbydefault=false",
    "--providers.docker.network=traefik_network",
    "--providers.file.directory=/config",
    "--providers.file.watch=true",
    "--entryPoints.web.address=:80",
    "--entryPoints.websecure.address=:443",
    "--log.level=INFO",
    "--accesslog=true"
  ]
  
  networks_advanced {
    name = docker_network.traefik_network.name
  }
  
  ports {
    internal = 80
    external = var.traefik_port_http
  }
  
  ports {
    internal = 443
    external = var.traefik_port_https
  }
  
  ports {
    internal = 8080
    external = var.traefik_port_dashboard
  }
  
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }
  
  volumes {
    host_path      = "${path.cwd}/certs"
    container_path = "/certs"
    read_only      = true
  }
  
  volumes {
    host_path      = "${path.cwd}/config"
    container_path = "/config"
    read_only      = true
  }
  
  depends_on = [
    local_file.traefik_dynamic_config,
    null_resource.create_traefik_directories
  ]
}

# Whoami Service (para teste) - HTTP e HTTPS
resource "docker_image" "whoami" {
  name = "traefik/whoami"
}

resource "docker_container" "whoami" {
  name  = "simple-service"
  image = docker_image.whoami.image_id
  
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.traefik_network.name
  }
  
  # Labels para HTTP
  labels {
    label = "traefik.enable"
    value = "true"
  }
  
  labels {
    label = "traefik.http.routers.whoami-http.rule"
    value = "Host(`whoami.${var.domain}`)"
  }
  
  labels {
    label = "traefik.http.routers.whoami-http.entrypoints"
    value = "web"
  }
  
  # Labels para HTTPS
  labels {
    label = "traefik.http.routers.whoami-https.rule"
    value = "Host(`whoami.${var.domain}`)"
  }
  
  labels {
    label = "traefik.http.routers.whoami-https.entrypoints"
    value = "websecure"
  }
  
  labels {
    label = "traefik.http.routers.whoami-https.tls"
    value = "true"
  }
  
  depends_on = [docker_container.traefik]
}

# Proxy para dashboard do Traefik via HTTPS
resource "docker_container" "traefik_dashboard_proxy" {
  name  = "traefik-dashboard-proxy"
  image = "traefik/whoami"
  
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.traefik_network.name
  }
  
  labels {
    label = "traefik.enable"
    value = "true"
  }
  
  # Dashboard HTTP
  labels {
    label = "traefik.http.routers.dashboard-http.rule"
    value = "Host(`traefik.${var.domain}`)"
  }
  
  labels {
    label = "traefik.http.routers.dashboard-http.entrypoints"
    value = "web"
  }
  
  labels {
    label = "traefik.http.routers.dashboard-http.service"
    value = "api@internal"
  }
  
  # Dashboard HTTPS
  labels {
    label = "traefik.http.routers.dashboard-https.rule"
    value = "Host(`traefik.${var.domain}`)"
  }
  
  labels {
    label = "traefik.http.routers.dashboard-https.entrypoints"
    value = "websecure"
  }
  
  labels {
    label = "traefik.http.routers.dashboard-https.tls"
    value = "true"
  }
  
  labels {
    label = "traefik.http.routers.dashboard-https.service"
    value = "api@internal"
  }
  
  depends_on = [docker_container.traefik]
}

