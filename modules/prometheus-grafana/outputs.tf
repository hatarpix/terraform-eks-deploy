output "ssh-tunnel" {
  value = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -f -N -L 5432:${var.grafana_db_host} -i ${var.ssh_private_path} ec2-user@${var.eks_node_ip}"
}