resource "helm_release" "loki" {
  name       = "loki"
  chart      = "loki"
  repository = "https://grafana.github.io/helm-charts"
  version    = "6.12.0"  # loki version 3.1.1
  namespace  = "loki"
  create_namespace = true

  values = [
    templatefile("${path.module}/loki-values.yaml.tpl", {
      role_arn         = aws_iam_role.loki_irsa_role.arn
      region           = var.region
      chunks_bucket    = aws_s3_bucket.loki_chunks.bucket
      ruler_bucket     = aws_s3_bucket.loki_ruler.bucket
      admin_bucket     = aws_s3_bucket.loki_admin.bucket
    })
  ]
}

resource "aws_s3_bucket" "loki_chunks" {
  bucket = "loki-${var.project_name}-chunks"
}

resource "aws_s3_bucket" "loki_ruler" {
  bucket = "loki-${var.project_name}-ruler"
}

resource "aws_s3_bucket" "loki_admin" {
  bucket = "loki-${var.project_name}-admin"
}

resource "helm_release" "promtail" {
  name             = "promtail"
  chart            = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  version          = "6.16.5"
  namespace        = "loki"
  create_namespace = true

  values = [
    <<EOF
config:
  clients:
    - url: http://loki-gateway.loki.svc.cluster.local/loki/api/v1/push
EOF
  ]
}