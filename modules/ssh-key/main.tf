resource "tls_private_key" "tls" {
  algorithm = var.key_algorithm
}

resource "aws_s3_object" "private_key" {
  key     = var.ssh_private_path
  bucket  = var.key_storage_bucket
  content = tls_private_key.tls.private_key_openssh
}

resource "aws_s3_object" "public_key" {
  key = var.ssh_key_path
  bucket  = var.key_storage_bucket
  content = tls_private_key.tls.public_key_openssh
}

resource "aws_key_pair" "aws_key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.tls.public_key_openssh
}
