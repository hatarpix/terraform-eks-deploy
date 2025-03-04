variable "domain_name" {
  description = "Domain name to manage"
  type        = string
}

variable "project_name" {
  description = "Project name to suffix resources"
  type        = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_provider_url" {
  type = string
}

variable "helm_external_dns_version" {
  type = string
}

variable "region" {
  type = string
}