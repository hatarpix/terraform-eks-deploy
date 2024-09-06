
# resource "aws_acm_certificate" "domain_ssl_certificate" {
#   private_key      = file(var.ssl_key_path)
#   certificate_body = file(var.ssl_cert_path)

#   tags = {
#     Name = var.domain_name
#   }
# }

resource "aws_acm_certificate" "domain_ssl_certificate" {
  private_key      = file(var.ssl_key_path)
  certificate_body = chomp(trimspace(format("%s-----END CERTIFICATE-----", element(split("-----END CERTIFICATE-----", file(var.ssl_cert_path)), 0))))
  certificate_chain = file(var.ssl_cert_path)
  tags = {
    Name = var.domain_name
  }
}

