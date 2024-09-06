variable "project_name" {
  description = "The name of the project"
  type        = string
}


variable "region" {
  description = "The AWS region"
  type        = string
}


variable "oidc_provider_arn" {
  description = "The OIDC provider ARN"
  type        = string
}

variable "oidc_provider_url" {
  description = "The OIDC provider URL"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "internal_ingress" {
  description = "Whether to create internal ingress rules"
  type        = number
}