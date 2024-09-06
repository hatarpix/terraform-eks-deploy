provider "aws" {
  alias = "dns_account"
  profile = var.dns_profile_name
}

provider "aws" {
  alias = "eks_account"
  profile = var.aws_profile_name
}


variable "region" {
  description = "The AWS region"
  type        = string
}

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

variable "aws_profile_name" {
  description = "The AWS profile name"
  type        = string
}

variable "dns_profile_name" {
  description = "The AWS profile name"
  type        = string
}