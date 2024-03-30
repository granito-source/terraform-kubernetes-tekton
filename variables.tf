variable "pipelines_version" {
    type        = string
    default     = null
    description = "Tekton Pipelines version"
}

variable "dashboard_version" {
    type        = string
    default     = null
    description = "Tekton Dashboard version"
}

variable "pac_version" {
    type        = string
    default     = null
    description = "Tekton Pipelines As Code version"
}

variable "dashboard_host" {
    type        = string
    default     = null
    description = "FQDN for the dashboard, must be set to configure ingress"
}

variable "pac_host" {
    type        = string
    default     = null
    description = "FQDN for Pipelines As Code, must be set to configure ingress"
}

variable "ingress_class" {
    type        = string
    default     = null
    description = "ingress class to use"
}

variable "issuer_name" {
    type        = string
    default     = null
    description = "cert-manager issuer, use TLS if defined"
}

variable "issuer_type" {
    type        = string
    default     = "cluster-issuer"
    description = "cert-manager issuer type"
    validation {
        condition     = contains(["cluster-issuer", "issuer"], var.issuer_type)
        error_message = "issuer type must be 'issuer' or 'cluster-issuer'"
    }
}

variable "username" {
    type        = string
    default     = "tekton"
    description = "Tekton dashboard username"
}

variable "password" {
    type        = string
    default     = null
    description = "Tekton dashboard password, must be set to configure ingress"
}
