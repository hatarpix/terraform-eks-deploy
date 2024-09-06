variable "region" {
  description = "The AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.100.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
  default     = ["10.100.0.0/20", "10.100.16.0/20", "10.100.32.0/20"]
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
  default     = ["10.100.48.0/20", "10.100.64.0/20", "10.100.80.0/20"]
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "project_name"
}

variable "ssh_key_name" {
  description = "The name of the SSH key pair to use"
  type        = string
  default     = "aws-key"
}

variable "ssh_key_path" {
  description = "The path to the SSH key pair to use"
  type        = string
  default     = "~/.ssh/id_k8s.pub"
}
