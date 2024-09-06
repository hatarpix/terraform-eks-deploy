variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the instance"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
}

variable "ssh_key_name" {
  description = "The name of the SSH key pair to use"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet for the instance"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

