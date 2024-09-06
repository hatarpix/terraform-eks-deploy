terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
    }
  }
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "grafana_host" {
  description = "The host of the Grafana instance"
  type        = string
}

variable "grafana_password" {
  description = "The password for the Grafana user"
  type        = string
}

variable "grafana_email" {
  description = "The email address for the Grafana user"
  type        = string
}

variable "grafana_db_host" {
  description = "The hostname of the Grafana database"
  type        = string
}

variable "grafana_db_user" {
  description = "The username for the Grafana database"
  type        = string
}

variable "grafana_db_name" {
  description = "The name of the Grafana database"
  type        = string
}

variable "grafana_db_password" {
  description = "The password for the Grafana database"
  type        = string
  sensitive   = true
}

variable "email_server" {
  description = "The email server for the project"
  type        = string
}

variable "email_port" {
  description = "The email port for the project"
  type        = string
}

variable "postgres_master_password" {
  description = " The password for the master DB user"
  type        = string
}

variable "eks_node_ip" {
  description = "The IP address of the EKS node"
  type        = string
}

variable "ssh_private_path" {
  description = "The path to the SSH private key"
  type        = string
}

variable "create_db" {
  description = "Whether to create the database"
  type        = bool
}