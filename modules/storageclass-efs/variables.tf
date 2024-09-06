variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed"
  type        = string
}

# Define the private subnets variable
variable "subnets" {
  description = "A list of private subnet IDs where the EKS cluster nodes will be deployed"
  type        = list(string)
}

# Define the project name variable
variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "oidc_provider_url" {
  description = "The URL of the OIDC provider for the EKS cluster"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC where the EKS cluster will be deployed"
  type        = string
}