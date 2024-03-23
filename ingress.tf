locals {
    configure_ingress = var.host != null
}

resource "kubernetes_ingress_v1" "dashboard" {
    depends_on = [kubectl_manifest.dashboard]
    count      = local.configure_ingress ? 1 : 0
    metadata {
        namespace = kubernetes_namespace_v1.pipelines.metadata[0].name
        name      = "tekton-dashboard"
        annotations = {
            "cert-manager.io/cluster-issuer" = "lets-encrypt"
        }
    }
    spec {
        ingress_class_name = var.ingress_class_name
        rule {
            host = var.host
            http {
                path {
                    path = "/"
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
            hosts = [var.host]
        }
    }
}
