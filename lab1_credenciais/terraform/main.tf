terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
  }
}

provider "vault" {
  address = "http://localhost:8200"
  skip_tls_verify = true
  token   = "root"
}

resource "vault_generic_secret" "app_secret" {
  path = "secret/data/app"
  data_json = jsonencode({
    username = "admin"
    password = "123456"
  })
}