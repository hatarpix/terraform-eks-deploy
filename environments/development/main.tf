provider "aws" {
  profile = var.aws_profile_name
  region  = var.region
}

provider "helm" {
  kubernetes {
    host                   = module.eks-cluster.eks_cluster_endpoint
    cluster_ca_certificate = module.eks-cluster.eks_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks-cluster.eks_cluster_name, "--region", var.region, "--profile", var.aws_profile_name]
    }
  }
}

provider "kubernetes" {
  host                   = module.eks-cluster.eks_cluster_endpoint
  cluster_ca_certificate = module.eks-cluster.eks_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks-cluster.eks_cluster_name, "--region", var.region, "--profile", var.aws_profile_name]
  }
}

terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}

provider "kubectl" {
  load_config_file       = false
  host                   = module.eks-cluster.eks_cluster_endpoint
  cluster_ca_certificate = module.eks-cluster.eks_ca_certificate
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks-cluster.eks_cluster_name, "--region", var.region, "--profile", var.aws_profile_name]
  }
}

module "vpc" {
  source               = "../../modules/vpc"
  vpc_cidr             = "10.100.0.0/16"
  public_subnet_cidrs  = ["10.100.0.0/20", "10.100.16.0/20", "10.100.32.0/20"]
  private_subnet_cidrs = ["10.100.48.0/20", "10.100.64.0/20", "10.100.80.0/20"]
  project_name         = var.project_name
  region               = var.region
  ssh_key_name         = var.ssh_key_name
  ssh_key_path         = var.ssh_key_path
}

# module "admin_vm" {
#   source         = "../../modules/admin-vm"
#   vpc_id         = module.vpc.vpc_id
#   ami_id         = "ami-06e89bbb5f88b3a34"  # Replace with the actual AMI ID for Ubuntu 22.04
#   instance_type  = "t3a.nano"
#   ssh_key_name   = var.ssh_key_name
#   subnet_id      = element(module.vpc.public_subnets, 0)  # Use the first public subnet ID
#   region         = var.region
#   vpc_cidr       = module.vpc.vpc_cidr
#   project_name   = var.project_name
# }
# output "admin_vm_instance_ip" {
#   value = module.admin_vm.instance_public_ip
# }

module "eks-cluster" {
  source           = "../../modules/eks"
  vpc_id           = module.vpc.vpc_id
  subnets          = module.vpc.public_subnets
  cluster_version  = var.cluster_version
  project_name     = var.project_name
  region           = var.region
  ssh_key_name     = var.ssh_key_name
  aws_profile_name = var.aws_profile_name
  depends_on       = [module.vpc]
}
output "claster_name" {
  value = module.eks-cluster.eks_cluster_name
}


resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.1"
  set {
    name  = "args"
    value = "{--kubelet-insecure-tls=true}"
  }
  depends_on = [module.eks-cluster]
}

module "storageclass-efs" {
  source = "../../modules/storageclass-efs"
  project_name = var.project_name
  oidc_provider_arn = module.eks-cluster.eks_oidc_provider_arn
  oidc_provider_url = module.eks-cluster.eks_oidc_provider_url
  subnets          = module.vpc.public_subnets
  vpc_cidr_block = module.vpc.vpc_cidr
  vpc_id = module.vpc.vpc_id
  depends_on = [ module.eks-cluster ]
}


module "ingress" {
  source            = "../../modules/ingress"
  project_name      = var.project_name
  region            = var.region
  oidc_provider_arn = module.eks-cluster.eks_oidc_provider_arn
  oidc_provider_url = module.eks-cluster.eks_oidc_provider_url
  cluster_name      = module.eks-cluster.eks_cluster_name
  vpc_id            = module.vpc.vpc_id
  internal_ingress  = 0 #yes or not    1 or 0
  depends_on        = [module.eks-cluster]
}

### For private subdomain
# module "certificate" {
#   source      = "../../modules/certificate"
#   domain_name = var.domain_name
# }
# output "dns_servers" {
#   value = module.certificate.dns_servers
# }

module "rds-postgres" {
  source                   = "../../modules/rds-postgres"
  project_name             = var.project_name
  postgres_instance_class   = var.postgres_instance_class
  postgres_master_password = var.postgres_master_password
  postgres_version         = var.postgres_version
  vpc_id                   = module.vpc.vpc_id
  vpc_cidr_block           = module.vpc.vpc_cidr
  public_subnets           = module.vpc.public_subnets
  private_subnets          = module.vpc.private_subnets
}

module "loki-stack" {
  source = "../../modules/loki-stack"
  project_name = var.project_name
  region = var.region
  oidc_provider_arn = module.eks-cluster.eks_oidc_provider_arn
  oidc_provider_url = module.eks-cluster.eks_oidc_provider_url
  depends_on = [ module.storageclass-efs ]
} 

module "external-secrets" {
  source = "../../modules/external-secrets"
  providers = {
    kubectl = kubectl
  }
  region = var.region
  project_name = var.project_name
  oidc_provider_arn = module.eks-cluster.eks_oidc_provider_arn
  oidc_provider_url = module.eks-cluster.eks_oidc_provider_url
  depends_on = [ module.ingress]
}

module "external-secrets-set" {
  source = "../../modules/external-secrets-set"
  email_user = var.email_user
  email_password = var.email_password
  ssl_cert_path = var.ssl_cert_path
  ssl_key_path = var.ssl_key_path
  domain_name = var.domain_name
}

module "prometheus-grafana" {
  source = "../../modules/prometheus-grafana"
  project_name = var.project_name
  grafana_password = var.grafana_password
  grafana_host = "${var.grafana_host}.${var.domain_name}"
  create_db = true
  grafana_db_host = module.rds-postgres.rds_endpoint
  grafana_db_user = var.grafana_db_user
  grafana_db_name = var.grafana_db_name
  grafana_db_password = var.grafana_db_password
  grafana_email = var.grafana_email
  email_server = var.email_server
  email_port = var.email_port
  postgres_master_password = var.postgres_master_password
  eks_node_ip = module.eks-cluster.node_ip
  ssh_private_path = var.ssh_private_path
}
output "ssh-tunnel" {
  value = module.prometheus-grafana.ssh-tunnel
}

module "argocd" {
  source = "../../modules/argocd"
  providers = {
    kubectl = kubectl
  }
  project_name = var.project_name
  argocd_host = "${var.argocd_host}-${var.project_name}.${var.domain_name}"
  argocd_rbac_entries = var.argocd_rbac_entries
  argocd_accounts_entries = var.argocd_accounts_entries
  depends_on = [ module.external-secrets ]
}
output "argocd_url" {
  value = module.argocd.argocd_url
}
output "argocd_admin_password" {
  value = module.argocd.argocd_admin_password
  sensitive = true
  ### terraform output -raw argocd_admin_password
}

module "external_dns" {
  source            = "../../modules/external_dns"
  project_name      = var.project_name
  domain_name       = var.domain_name
  region            = var.region
  oidc_provider_arn = module.eks-cluster.eks_oidc_provider_arn
  oidc_provider_url = module.eks-cluster.eks_oidc_provider_url
  aws_profile_name  = var.aws_profile_name
  dns_profile_name  = var.dns_profile_name
}


