resource "kubernetes_namespace_v1" "pipelines" {
    metadata {
        name = "tekton-pipelines"
    }
    lifecycle {
        ignore_changes = [metadata[0].labels]
    }
}

resource "kubernetes_namespace_v1" "pipelines_resolvers" {
    metadata {
        name = "tekton-pipelines-resolvers"
    }
    lifecycle {
        ignore_changes = [metadata[0].labels]
    }
}

data "http" "pipelines" {
    url = "https://storage.googleapis.com/tekton-releases/pipeline/previous/v${var.pipelines_version}/release.yaml"
}

data "kubectl_file_documents" "pipelines" {
    content = data.http.pipelines.response_body
}

resource "kubectl_manifest" "pipelines" {
    depends_on = [
        kubernetes_namespace_v1.pipelines,
        kubernetes_namespace_v1.pipelines_resolvers
    ]
    for_each  = data.kubectl_file_documents.pipelines.manifests
    yaml_body = each.value
}

data "http" "dashboard" {
    url = "https://storage.googleapis.com/tekton-releases/dashboard/previous/v${var.dashboard_version}/release.yaml"
}

data "kubectl_file_documents" "dashboard" {
    content = data.http.dashboard.response_body
}

resource "kubectl_manifest" "dashboard" {
    depends_on = [kubernetes_namespace_v1.pipelines]
    for_each   = data.kubectl_file_documents.dashboard.manifests
    yaml_body  = each.value
}
