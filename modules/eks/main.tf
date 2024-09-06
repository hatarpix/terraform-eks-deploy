module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.24.0" 
  cluster_name    = "eks-${var.project_name}"
  cluster_version = var.cluster_version
  subnet_ids      = var.subnets
  vpc_id          = var.vpc_id
  enable_irsa     = true
  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true
  enable_cluster_creator_admin_permissions = true

  eks_managed_node_group_defaults = {
    create_before_destroy = true
    authentication_mode = "API_AND_CONFIG_MAP"
    use_custom_launch_template = false
    disk_size        = 50
    disk_type        = "gp3"
    ebs_optimized    = true
    remote_access = {
      ec2_ssh_key               = var.ssh_key_name
    }
    tags = {
      "Environment" = "dev"
      "Terraform"   = "true"
      "Name"        = "worker-${var.project_name}"
    }
  }

  eks_managed_node_groups = {
    worker-node-1 = {
      instance_types       = ["t3a.large"] # 
      capacity_type        = "ON_DEMAND"
      min_size             = 1
      max_size             = 5
      desired_size         = 2
      labels = {
        "name"        = "worker-1-${var.project_name}"
        "environment" = "dev"
      }
      tags = {
        "Environment" = "dev"
        "Terraform"   = "true"
        "Name"        = "worker-${var.project_name}-1"
      }
    }
    # app-node-1 = {
    #   instance_types       = ["m7i.xlarge", "c7i.xlarge", "c5.xlarge", "m5.xlarge"] # 4-16, 4-8
    #   spot_price    = "0.15"
    #   capacity_type  = "SPOT"
    #   spot_instance_pools  = 2
    #   min_size             = 1
    #   max_size             = 6
    #   desired_size         = 2
    #   labels = {
    #     "name"        = "app-${local.prefix}"
    #     "environment" = "prod"
    #     "role"        = "app"
    #   }
    #   tags = {
    #     "Environment" = "prod"
    #     "Terraform"   = "true"
    #     "Name"        = "worker-${local.prefix}"
    #   }
    #   taints = {
    #     dedicated = {
    #     key    = "role"
    #     value  = "app"
    #     effect = "PREFER_NO_SCHEDULE"
    #     }
    #   }
    # }
  }

  cluster_addons = {
    coredns                = {addon_version = "v1.11.1-eksbuild.8"}
    eks-pod-identity-agent = {addon_version = "v1.3.2-eksbuild.2"}
    kube-proxy             = {addon_version = "v1.30.0-eksbuild.3"}
    vpc-cni                = {
      addon_version = "v1.18.1-eksbuild.3"
      before_compute = true
      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })}
    aws-efs-csi-driver = {
      addon_version = "v2.0.7-eksbuild.1"
      service_account_role_arn  = aws_iam_role.efs_csi_driver_role.arn
    }
  }

  tags = {
    Name    = "eks-${var.project_name}"
    Project = var.project_name
    Terraform  = "true"
  }

}
