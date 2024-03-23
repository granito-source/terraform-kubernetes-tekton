locals {
    protocol = var.issuer_name == null ? "http" : "https"
}

output "dashboard_url" {
    depends_on  = [kubectl_manifest.dashboard]
    value       = local.configure_ingress ? "${local.protocol}://${var.host}/" : null
    description = "installed application URL"
}
