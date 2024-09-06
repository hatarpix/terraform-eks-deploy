resource "aws_security_group" "efs_sg" {
  name        = "efs-security-group-${var.project_name}"
  description = "Security group for EFS mount targets"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "efs-sg-${var.project_name}"
  }
}

resource "aws_efs_file_system" "this" {
  creation_token = "efs-token-${var.project_name}-utoken"  # Replace with your chosen unique token
  encrypted      = true 
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "efs-${var.project_name}"
  }
}

resource "aws_efs_mount_target" "this" {
  count           = length(var.subnets) # Assuming var.subnets is a list of subnet IDs
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = element(var.subnets, count.index)
  security_groups = [aws_security_group.efs_sg.id]
  depends_on = [aws_efs_file_system.this]
}

resource "kubernetes_storage_class" "efs_sc" {
  metadata {
    name = "efs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner = "efs.csi.aws.com"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = aws_efs_file_system.this.id
    directoryPerms   = "700"
    gidRangeStart    = "1000"
    gidRangeEnd      = "2000"
    basePath         = "/dynamic_provisioning"
  }

  reclaim_policy       = "Retain"
  volume_binding_mode  = "WaitForFirstConsumer"

  depends_on = [aws_efs_file_system.this]
}
