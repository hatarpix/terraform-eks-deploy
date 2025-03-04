variable "email_user" {
  description = "Email user"
  type = string
}

variable "email_password" {
  description = "Email password"
  sensitive   = true
  type = string
}

variable "project_name" {
  type = string
}