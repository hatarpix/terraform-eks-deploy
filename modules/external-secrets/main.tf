# Install External Secrets

resource "aws_iam_role" "es_role" {
  name = "external_secrets_role-${var.project_name}"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${var.oidc_provider_arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${var.oidc_provider_url}:sub": "system:serviceaccount:external-secrets:external-secrets-sa",
                    "${var.oidc_provider_url}:aud": "sts.amazonaws.com"
                }
            }
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.es_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}


resource "helm_release" "external-secrets" {
  name             = "external-secrets"
  # repository       = "https://charts.external-secrets.io"
  # chart            = "external-secrets"
  chart = "./${path.module}/external-secrets-0.10.2.tgz"
  namespace        = "external-secrets"
  create_namespace = true

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.es_role.arn
  }

  set {
    name  = "serviceAccount.name"
    value = "external-secrets-sa"
  }
}


resource "kubectl_manifest" "aws_parameter_store" {
  yaml_body = <<-EOT
apiVersion: external-secrets.io/v1alpha1
kind: ClusterSecretStore
metadata:
  name: aws-parameter-store
spec:
  provider:
    aws:
      service: ParameterStore
      region: ${var.region}
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets-sa
            namespace: external-secrets
EOT

  depends_on = [helm_release.external-secrets]
}

