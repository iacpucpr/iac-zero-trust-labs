output "pg_password" {
  description = "Generated PostgreSQL password"
  value       = random_password.pg_pass.result
  sensitive   = true
}

output "authentik_secret_key" {
  description = "Generated Authentik secret key"
  value       = random_password.authentik_secret_key.result
  sensitive   = true
}

output "authentik_url_http" {
  description = "Authentik HTTP URL"
  value       = "http://:auth.7f000001.nip.io:${var.compose_port_http}"
}

output "authentik_url_https" {
  description = "Authentik HTTPS URL"
  value       = "https://auth.7f000001.nip.io:${var.compose_port_https}"
}

