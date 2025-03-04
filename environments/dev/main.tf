terraform {
  backend "s3" {
    bucket = "terraform-state-env"
    key    = "k8s-dev/terraform.tfstate"
    region = "us-east-1"
  }
}

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

module "ssh_key" {
  source             = "../../modules/ssh-key"
  key_name           = "${var.ssh_key_name}-${var.project_name}"
  key_storage_bucket = var.s3_bucket_state
  ssh_key_path       = var.ssh_key_path
  ssh_private_path   = var.ssh_private_path
  key_algorithm      = "ED25519"
}


# for use with existing VPC
# !!!!! add tag to the Subnets     kubernetes.io/role/elb=1
module "vpc" {
  source          = "../../modules/vpc_fake"
  vpc_id          = "vpc-......"
  vpc_cidr        = "10........"
  public_subnets  = ["subnet-.......", "subnet-........"]
  private_subnets = ["", ""]
}

# module vrsion https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
module "eks-cluster" {
  source               = "../../modules/eks"
  vpc_id               = module.vpc.vpc_id
  subnets              = module.vpc.public_subnets
  cluster_version      = "1.32"
  project_name         = var.project_name
  region               = var.region
  ssh_key_name         = module.ssh_key.key_name
  aws_profile_name     = var.aws_profile_name # for kubeconfig
  depends_on           = [module.vpc]
  coredns_version      = "v1.11.4-eksbuild.2"
  pod_identity_version = "v1.3.4-eksbuild.1"
  kube_proxy_version   = "v1.32.0-eksbuild.2"
  cni_version          = "v1.19.2-eksbuild.1"
  efs_csi_version      = "v2.1.4-eksbuild.1"
}
output "cluster_name" {
  value = module.eks-cluster.eks_cluster_name
}

# https://artifacthub.io/packages/helm/metrics-server/metrics-server
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.12.2"
  set {
    name  = "args"
    value = "{--kubelet-insecure-tls=true}"
  }
  depends_on = [module.eks-cluster]
}

module "storageclass-efs" {
  source            = "../../modules/storageclass-efs"
  project_name      = var.project_name
  oidc_provider_arn = module.eks-cluster.eks_oidc_provider_arn
  oidc_provider_url = module.eks-cluster.eks_oidc_provider_url
  subnets           = module.vpc.public_subnets
  vpc_cidr_block    = module.vpc.vpc_cidr
  vpc_id            = module.vpc.vpc_id

  depends_on        = [module.eks-cluster]
}


module "ingress" {
  source               = "../../modules/ingress"
  project_name         = var.project_name
  region               = var.region
  oidc_provider_arn    = module.eks-cluster.eks_oidc_provider_arn
  oidc_provider_url    = module.eks-cluster.eks_oidc_provider_url
  cluster_name         = module.eks-cluster.eks_cluster_name
  vpc_id               = module.vpc.vpc_id
  # https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller
  helm_alb_version     = "1.11.0"
  # https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
  helm_ingress_version = "4.12.0"
  certificate_arn = var.certificate_arn

  depends_on = [module.eks-cluster]
}

module "loki-stack" {
  source            = "../../modules/loki-stack"
  project_name      = var.project_name
  region            = var.region
  oidc_provider_arn = module.eks-cluster.eks_oidc_provider_arn
  oidc_provider_url = module.eks-cluster.eks_oidc_provider_url
  # https://artifacthub.io/packages/helm/grafana/loki
  helm_version      = "6.25.0" # loki version 3.3.2

  depends_on        = [module.storageclass-efs]
}

module "external-secrets" {
  source = "../../modules/external-secrets"
  providers = {
    kubectl = kubectl
  }
  region            = var.region
  project_name      = var.project_name
  oidc_provider_arn = module.eks-cluster.eks_oidc_provider_arn
  oidc_provider_url = module.eks-cluster.eks_oidc_provider_url
  # https://artifacthub.io/packages/helm/external-secrets-operator/external-secrets
  helm_version     = "0.14.0"

  depends_on        = [module.ingress]
}

module "external-secrets-set" {
  source         = "../../modules/external-secrets-set"
  project_name   = var.project_name
  email_user     = var.email_user
  email_password = var.email_password
  depends_on     = [module.external-secrets]
}

module "prometheus-grafana" {
  source              = "../../modules/prometheus-grafana"
  project_name        = var.project_name
  grafana_password    = var.grafana_password
  grafana_host        = "grafana.${var.domain_name}"
  grafana_db_host     = var.grafana_db_host
  grafana_db_user     = var.grafana_db_user
  grafana_db_name     = var.grafana_db_name
  grafana_db_password = var.grafana_db_password
  grafana_email       = var.grafana_email
  email_server        = var.email_server
  email_port          = var.email_port
  # https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack
  helm_version        = "68.4.4"
  depends_on          = [module.external-secrets-set-dev]
}

module "argocd" {
  source = "../../modules/argocd"
  providers = {
    kubectl = kubectl
  }
  project_name            = var.project_name
  argocd_host             = "argocd.${var.domain_name}"
  argocd_rbac_entries     = var.argocd_rbac_entries
  argocd_accounts_entries = var.argocd_accounts_entries
  depends_on              = [module.external-secrets]
  # https://artifacthub.io/packages/helm/argo/argo-cd/7.7.3
  helm_argocd_version     = "7.7.22"
}
output "argocd_url" {
  value = module.argocd.argocd_url
}
output "argocd_admin_password" {
  value     = module.argocd.argocd_admin_password
  sensitive = true
  ### terraform output -raw argocd_admin_password
}

module "irsa-api" {
  source            = "../../modules/irsa-api"
  project_name      = var.project_name
  oidc_provider_arn = module.eks-cluster.eks_oidc_provider_arn
  oidc_provider_url = module.eks-cluster.eks_oidc_provider_url
}
output "service_account" {
  value = module.irsa-api.service_account
}



# for Dev
module "external-dns" {
  source                    = "../../modules/external-dns"
  project_name              = var.project_name
  domain_name               = var.domain_name
  region                    = var.region
  oidc_provider_arn         = module.eks-cluster.eks_oidc_provider_arn
  oidc_provider_url         = module.eks-cluster.eks_oidc_provider_url
  helm_external_dns_version = "1.15.1"

  depends_on = [module.eks-cluster]
}


