locals {
    protocol = var.issuer_name == null ? "http" : "https"
}

output "dashboard_url" {
    depends_on  = [kubernetes_ingress_v1.dashboard]
    value       = local.configure_dashboard_ingress ? "${local.protocol}://${var.dashboard_host}/" : null
    description = "installed dashboard URL"
}

output "pac_url" {
    depends_on  = [kubernetes_ingress_v1.pac]
    value       = local.configure_pac_ingress ? "${local.protocol}://${var.pac_host}/" : null
    description = "installed PAC ingress URL"
}
