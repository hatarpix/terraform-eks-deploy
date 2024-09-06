

# Store email_user in SSM Parameter Store
resource "aws_ssm_parameter" "email_user" {
  name  = "/global/email_user"
  type  = "String"
  value = var.email_user
}

# Store email_password in SSM Parameter Store
resource "aws_ssm_parameter" "email_password" {
  name  = "/global/email_password"
  type  = "SecureString"
  value = var.email_password
}

resource "aws_ssm_parameter" "ssl_key" {
  name  = "/global/ssl_key"
  type  = "String"
  value = file(var.ssl_key_path)
  tier  = "Intelligent-Tiering"
}

resource "aws_ssm_parameter" "ssl_cert" {
  name  = "/global/ssl_cert"
  type  = "String"
  value = file(var.ssl_cert_path)
  tier  = "Intelligent-Tiering"
}