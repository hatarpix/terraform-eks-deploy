resource "aws_security_group" "admin_sg" {
  vpc_id = var.vpc_id

  // Allow SSH access from the internet
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access from the internet"
  }

  // Allow all traffic from the VPC CIDR block
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow all traffic from the VPC CIDR block"
  }

  // Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "admin-sg-${var.project_name}"
    Terraform  = "true"
  }
}


resource "aws_instance" "admin_vm" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.admin_sg.id]
  
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    delete_on_termination = true

    tags = {
      Name = "admin-vm-${var.project_name}-root"
    }
  }

  tags = {
    Name = "admin-vm-${var.project_name}"
    Terraform  = "true"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install -y mc tcpdump
              EOF
}