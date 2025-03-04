
# Store email_user in SSM Parameter Store
resource "aws_ssm_parameter" "email_user" {
  name  = "/${var.project_name}/email_user"
  type  = "String"
  value = var.email_user
}

# Store email_password in SSM Parameter Store
resource "aws_ssm_parameter" "email_password" {
  name  = "/${var.project_name}/email_password"
  type  = "SecureString"
  value = var.email_password
}

