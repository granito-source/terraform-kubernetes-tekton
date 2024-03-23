resource "terraform_data" "username" {
    input = var.username
}

resource "terraform_data" "password" {
    input = var.password
}

locals {
    configure_ingress = var.host != null && var.password != null
}

resource "kubernetes_secret" "dashboard_auth" {
    count = local.configure_ingress ? 1 : 0
    metadata {
        namespace = kubernetes_namespace_v1.pipelines.metadata[0].name
        name      = "dashboard-auth"
    }
    data = {
        (terraform_data.username.output) = bcrypt(terraform_data.password.output)
    }
    lifecycle {
        replace_triggered_by = [
            terraform_data.username,
            terraform_data.password
        ]
        ignore_changes = [
            data
        ]
    }
}

resource "kubernetes_ingress_v1" "dashboard" {
    depends_on = [kubectl_manifest.dashboard]
    count      = local.configure_ingress ? 1 : 0
    metadata {
        namespace   = kubernetes_namespace_v1.pipelines.metadata[0].name
        name        = "tekton-dashboard"
        annotations = {
            "cert-manager.io/${var.issuer_type}"           = var.issuer_name
            "nginx.ingress.kubernetes.io/auth-type"        = "basic"
            "nginx.ingress.kubernetes.io/auth-secret"      = kubernetes_secret.dashboard_auth[0].metadata[0].name
            "nginx.ingress.kubernetes.io/auth-secret-type" = "auth-map"
            "nginx.ingress.kubernetes.io/auth-realm"       = "Tekton"
        }
    }
    spec {
        ingress_class_name = var.ingress_class_name
        rule {
            host = var.host
            http {
                path {
                    path      = "/"
                    path_type = "Prefix"
                    backend {
                        service {
                            name = "tekton-dashboard"
                            port {
                                number = 9097
                            }
                        }
                    }
                }
            }
        }
        tls {
            secret_name = "tekton-dashboard-tls"
            hosts       = [var.host]
        }
    }
}
