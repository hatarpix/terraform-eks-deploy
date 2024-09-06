variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type = string
}

variable "postgres_instance_class" {
  description = "The instance type for the RDS instance"
  type = string
}

variable "postgres_master_password" {
  description = "The password for the master DB user"
  type        = string
  sensitive   = true
}

variable "postgres_version" {
  description = "The version of PostgreSQL to use"
  type = string
}