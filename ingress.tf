locals {
    configure_dashboard_ingress = var.dashboard_host != null && var.password != null
    configure_pac_ingress       = var.pac_host != null
}

resource "terraform_data" "username" {
    input = var.username
}

resource "terraform_data" "password" {
    input = var.password
}

resource "kubernetes_secret" "dashboard_auth" {
    count = local.configure_dashboard_ingress ? 1 : 0
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
    count      = local.configure_dashboard_ingress ? 1 : 0
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
        ingress_class_name = var.ingress_class
        rule {
            host = var.dashboard_host
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
            hosts       = [var.dashboard_host]
        }
    }
}

resource "kubernetes_ingress_v1" "pac" {
    depends_on = [kubectl_manifest.pac]
    count      = local.configure_pac_ingress ? 1 : 0
    metadata {
        namespace   = kubernetes_namespace_v1.pac.metadata[0].name
        name        = "tekton-pac"
        annotations = {
            "cert-manager.io/${var.issuer_type}" = var.issuer_name
        }
    }
    spec {
        ingress_class_name = var.ingress_class
        rule {
            host = var.pac_host
            http {
                path {
                    path      = "/"
                    path_type = "Prefix"
                    backend {
                        service {
                            name = "pipelines-as-code-controller"
                            port {
                                number = 8080
                            }
                        }
                    }
                }
            }
        }
        tls {
            secret_name = "tekton-pac-tls"
            hosts       = [var.pac_host]
        }
    }
}
