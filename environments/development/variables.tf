variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile_name" {
  description = "The AWS profile name"
  type        = string
  default     = "dev-profile"
}

variable "dns_profile_name" {
  description = "The AWS profile name"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "dev"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "ssh_key_name" {
  description = "The name of the SSH key pair to use"
  type        = string
  default     = "k8s-key"
}

variable "ssh_key_path" {
  description = "The path to the SSH key pair to use"
  type        = string
  default     = "~/.ssh/id_k8s.pub"
}

variable "ssh_private_path" {
  description = "The path to the SSH key pair to use"
  type        = string
  default     = "~/.ssh/id_k8s"
}

variable "domain_name" {
  description = "The domain name for the project"
  type        = string
  default     = "name.com"
}

variable "postgres_instance_class" {
  description = "The instance type for the RDS instance"
  type = string
  default = "db.t3.micro"
}

variable "postgres_version" {
  description = "The version of PostgreSQL to use"
  type = string
  default = "16.3"
}

variable "postgres_master_password" {
  description = "The password for the master DB user"
  type        = string
  sensitive   = true
  default = "dbpassword"
}

variable "email_server" {
  description = "The email server for the project"
  type        = string
  default     = "smtp.gmail.com"
}

variable "email_port" {
  description = "The email port for the project"
  type        = string
  default     = "587"
}

variable "email_user" {
  description = "The email user for the project"
  type        = string
  default     = "email@gmail.com"
}

variable "email_password" {
  description = "The email password for the project"
  type        = string
  sensitive   = true
  default     = "password"
}

variable "email_from" {
  description = "The email from for the project"
  type        = string
  default     = "email@gmail.com"
}

variable "ssl_key_path" {
  description = "The path to the SSH key pair to use"
  type        = string
  default     = "~/.ssh/key.pem"
}

variable "ssl_cert_path" {
  description = "The path to the SSL certificate to use"
  type        = string
  default     = "~/.ssh/cert.pem"
}

variable "grafana_password" {
  description = "The password for the Grafana user"
  type        = string
  sensitive   = true
  default     = "password"
}

variable "grafana_host" {
  description = "The host for the Grafana user"
  type        = string
  default     = "grafana.host.com"
}

variable "grafana_email" {
  description = "The email for the Grafana user"
  type        = string
  default     = "email@gmail.com"
}

variable "grafana_db_host" {
  description = "The hostname of the Grafana database"
  type        = string
  default     = "postgres.host.com"
}

variable "grafana_db_user" {
  description = "The username for the Grafana database"
  type        = string
  default     = "postgres"
}

variable "grafana_db_name" {
  description = "The name of the Grafana database"
  type        = string
  default     = "postgres"
}

variable "grafana_db_password" {
  description = "The password for the Grafana database"
  type        = string
  sensitive   = true
  default = "dbpassword"
}

variable "argocd_host" {
  description = "The host for the Grafana user"
  type        = string
  default     = "argocd"
}

variable "argocd_rbac_entries" {
  description = "List of RBAC entries for ConfigMap"
  type = list(object({
    user = string
    role = string
  }))
  default = []
}

variable "argocd_accounts_entries" {
  description = "List of RBAC entries for ConfigMap"
  type = list(object({
    user = string
    permissions = string
  }))
  default = []
}

