output "public_key" {
  value = tls_private_key.tls.public_key_openssh
}

output "private_key" {
  value = tls_private_key.tls.private_key_openssh
}

output "key_name" {
  value = var.key_name
}

#resource "local_file" "ssh_private_key" {
#  content         = tls_private_key.tls.private_key_openssh
#  filename        = "/tmp/ssh-${var.key_name}"
#  file_permission = "0600"
#}
