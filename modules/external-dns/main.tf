
resource "helm_release" "external_dns" {
  name       = "external-dns-${var.project_name}"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = var.helm_external_dns_version
  
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
    value = aws_iam_role.external_dns.arn
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

}


resource "aws_iam_role" "external_dns" {
  name = "${var.project_name}-external-dns-role"

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
            "${var.oidc_provider_url}:sub" : "system:serviceaccount:kube-system:external-dns-sa",
            "${var.oidc_provider_url}:aud" : "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}