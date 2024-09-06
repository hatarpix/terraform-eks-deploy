output "certificate_arn" {
  value       = aws_acm_certificate.domain_ssl_certificate.arn
  description = "ARN of the uploaded SSL certificate"
}
