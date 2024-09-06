variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "The URL of the OIDC provider"
  type        = string
}