terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0" # Use the appropriate version
    }
  }
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "argocd_host" {
  description = "The host of the argocd URL"
  type        = string
}

variable "argocd_rbac_entries" {
  description = "The RBAC entries for the argocd"
  type = list(object({
    user = string
    role = string
  }))
}

variable "argocd_accounts_entries" {
  description = "The RBAC entries for the argocd"
  type = list(object({
    user        = string
    permissions = string
  }))
}
