

resource "helm_release" "external_dns" {
  name       = "external-dns-${var.project_name}-assets"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.14.5"
  
  set {
    name  = "provider"
    value = "aws"
  }
  set {
    name  = "aws.zoneType"
    value = "public"
  }
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "serviceAccount.name"
    value = "external-dns-sa"
  }
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.eks_dns_role.arn
  }
  set {
    name  = "rbac.create"
    value = "true"
  }
  set {
    name  = "aws.region"
    value = var.region
  }
  set {
    name  = "domainFilters[0]"
    value = var.domain_name
  }
  set {
    name  = "extraArgs[0]"
    value = "--aws-assume-role=${aws_iam_role.dns_account_role.arn}"
  }
}

# Current EKS AWS account
resource "aws_iam_role" "eks_dns_role" {
  provider = aws.eks_account
  name     = "external_dns_eks_role-${var.project_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider_url}:sub" = "system:serviceaccount:kube-system:external-dns-sa"
            "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Current EKS AWS account
resource "aws_iam_role_policy" "eks_assume_role_policy" {
  provider = aws.eks_account
  name     = "eks_assume_dns_role_policy"
  role     = aws_iam_role.eks_dns_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Resource = aws_iam_role.dns_account_role.arn
      }
    ]
  })
}

# AWS DNS account
resource "aws_iam_role" "dns_account_role" {
  provider = aws.dns_account
  name     = "external_dns_route53_role-${var.project_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.eks_dns_role.arn
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# AWS DNS account
resource "aws_iam_role_policy_attachment" "dns_account_policy" {
  provider   = aws.dns_account
  role       = aws_iam_role.dns_account_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}