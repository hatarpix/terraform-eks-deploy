output "certificate_arn" {
  value = aws_acm_certificate.wildcard_cert.arn
}

output "dns_servers" {
  value = aws_route53_zone.domain_zone.name_servers
}
