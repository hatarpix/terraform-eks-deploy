variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be deployed"
  type        = string
}

# Define the private subnets variable
variable "subnets" {
  description = "A list of private subnet IDs where the EKS cluster nodes will be deployed"
  type        = list(string)
}

# Define the cluster version variable
variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
}

# Define the project name variable
variable "project_name" {
  description = "The name of the project"
  type        = string
}

# Define the AWS region variable
variable "region" {
  description = "The AWS region where the EKS cluster will be deployed"
  type        = string
}

variable "ssh_key_name" {
  description = "The name of the SSH key pair to use"
  type        = string
}

variable "aws_profile_name" {
  description = "The AWS profile name"
  type        = string
}