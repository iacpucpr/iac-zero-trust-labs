output "traefik_dashboard_url_http" {
  description = "Traefik Dashboard HTTP URL"
  value       = "http://traefik.${var.domain}"
}

output "traefik_dashboard_url_https" {
  description = "Traefik Dashboard HTTPS URL"
  value       = "https://traefik.${var.domain}"
}

output "traefik_dashboard_direct" {
  description = "Traefik Dashboard Direct URL"
  value       = "http://localhost:${var.traefik_port_dashboard}"
}

output "whoami_service_url_http" {
  description = "Whoami service HTTP URL"
  value       = "http://whoami.${var.domain}"
}

output "whoami_service_url_https" {
  description = "Whoami service HTTPS URL"
  value       = "https://whoami.${var.domain}"
}

output "certificate_requirements" {
  description = "Required certificate files"
  value = {
    cert_file = "${path.cwd}/certs/traefik.crt"
    key_file  = "${path.cwd}/certs/traefik.key"
    note      = "Place your certificate and key files in the certs directory"
  }
}

