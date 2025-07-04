terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

# Módulo Baseline: sempre é chamado, mas seu comportamento muda com as variáveis
module "baseline" {
  source = "./modules/baseline"

  # Lógica de controle: se lab A ou B estiver ativo, não publique a porta
  publish_glpi_port = !(var.enable_lab_a || var.enable_lab_b)

  # Adiciona as labels do Traefik apenas se o Lab A estiver ativo
  glpi_labels = var.enable_lab_a ? {
    "traefik.enable"                                     = "true"
    "traefik.http.routers.glpi.rule"                     = "Host(`glpi.local.gd`)"
    "traefik.http.routers.glpi.entrypoints"              = "websecure"
    "traefik.http.routers.glpi.tls.certresolver"         = "myresolver"
    "traefik.http.services.glpi.loadbalancer.server.port" = "80"
    "traefik.http.routers.glpi.middlewares"              = "authentik@docker"
    } : {}
}

# Módulo Lab A: só é chamado se enable_lab_a for true
module "lab_a" {
  source = "./modules/lab_a_app_layer"
  count  = var.enable_lab_a ? 1 : 0

  # Passa o nome da rede criada pelo módulo baseline
  network_name = module.baseline.network_name
}

# Módulo Lab B: só é chamado se enable_lab_b for true
module "lab_b" {
  source = "./modules/lab_b_network_layer"
  count  = var.enable_lab_b ? 1 : 0

  # Passa as informações necessárias
  network_name           = module.baseline.network_name
  twingate_access_token  = var.twingate_access_token
  twingate_refresh_token = var.twingate_refresh_token
  twingate_network       = var.twingate_network
}


# --- Geração do Inventário Ansible ---
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible/templates/inventory.tftpl", {
    glpi_name    = module.baseline.glpi_container_name
    mariadb_name = module.baseline.mariadb_container_name
  })
  filename = "${path.module}/ansible/dynamic_inventory.ini"
}