output "instance_id" {
  value = aws_instance.admin_vm.id
}

output "instance_public_ip" {
  value = aws_instance.admin_vm.public_ip
}
