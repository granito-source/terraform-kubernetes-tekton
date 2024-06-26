resource "kubernetes_namespace_v1" "pipelines" {
    metadata {
        name = "tekton-pipelines"
    }
    lifecycle {
        ignore_changes = [metadata[0].labels]
    }
}

resource "kubernetes_namespace_v1" "resolvers" {
    metadata {
        name = "tekton-pipelines-resolvers"
    }
    lifecycle {
        ignore_changes = [metadata[0].labels]
    }
}

resource "kubernetes_namespace_v1" "pac" {
    metadata {
        name = "pipelines-as-code"
    }
    lifecycle {
        ignore_changes = [metadata[0].labels]
    }
}

locals {
    pipelines_version = var.pipelines_version == null ? "latest" : "previous/v${var.pipelines_version}"
    dashboard_version = var.dashboard_version == null ? "latest" : "previous/v${var.dashboard_version}"
    pac_url           = var.pac_version == null ?
    "https://raw.githubusercontent.com/openshift-pipelines/pipelines-as-code/stable/release.k8s.yaml" :
    "https://github.com/openshift-pipelines/pipelines-as-code/releases/download/${var.pac_version}/release.k8s.yaml"
}

data "http" "pipelines" {
    url = "https://storage.googleapis.com/tekton-releases/pipeline/${local.pipelines_version}/release.yaml"
}

data "kubectl_file_documents" "pipelines" {
    content = data.http.pipelines.response_body
}

resource "kubectl_manifest" "pipelines" {
    depends_on = [
        kubernetes_namespace_v1.pipelines,
        kubernetes_namespace_v1.resolvers
    ]
    for_each  = data.kubectl_file_documents.pipelines.manifests
    yaml_body = each.value
}

data "http" "dashboard" {
    url = "https://storage.googleapis.com/tekton-releases/dashboard/${local.dashboard_version}/release.yaml"
}

data "kubectl_file_documents" "dashboard" {
    content = data.http.dashboard.response_body
}

resource "kubectl_manifest" "dashboard" {
    depends_on = [kubectl_manifest.pipelines]
    for_each   = data.kubectl_file_documents.dashboard.manifests
    yaml_body  = each.value
}

data "http" "pac" {
    url = local.pac_url
}

data "kubectl_file_documents" "pac" {
    content = data.http.pac.response_body
}

resource "kubectl_manifest" "pac" {
    depends_on = [
        kubernetes_namespace_v1.pac,
        kubectl_manifest.pipelines
    ]
    for_each  = data.kubectl_file_documents.pac.manifests
    yaml_body = each.value
}
