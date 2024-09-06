variable "email_user" {
  description = "Email user"
  type = string
}

variable "email_password" {
  description = "Email password"
  sensitive   = true
  type = string
}

variable "ssl_key_path" {
  description = "SSL key"
  type = string
}

variable "ssl_cert_path" {
  description = "SSL cert"
  type = string
}

variable "domain_name" {
  description = "Domain name"
  type = string
}