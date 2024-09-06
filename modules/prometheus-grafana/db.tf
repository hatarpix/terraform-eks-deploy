# Local-exec provisioner to create an SSH tunnel
resource "null_resource" "ssh_tunnel" {
  count = var.create_db ? 1 : 0
  provisioner "local-exec" {
    command = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -f -N -L 5432:${var.grafana_db_host} -i ${var.ssh_private_path} ec2-user@${var.eks_node_ip}"
  }
}


provider "postgresql" {
  host     = "localhost"
  port     = 5432
  database = "postgres"
  username = "postgres"
  password = var.postgres_master_password
  sslmode  = "require"
  superuser = false
}

resource "postgresql_role" "grafana_user" {
  count = var.create_db ? 1 : 0
  name     = var.grafana_db_user
  password = var.grafana_db_password
  login    = true
  depends_on = [ null_resource.ssh_tunnel]
}

resource "postgresql_database" "grafana_db" {
  count = var.create_db ? 1 : 0
  name = var.grafana_db_name
  owner = var.grafana_db_user
  depends_on = [ postgresql_role.grafana_user ]
}

