resource "random_id" "suffix" {
  byte_length = 4
}

resource "helm_release" "loki" {
  name       = "loki"
  chart      = "loki"
  repository = "https://grafana.github.io/helm-charts"
  version    = var.helm_version
  namespace  = "loki"
  create_namespace = true

  values = [
    templatefile("${path.module}/loki-values.yaml.tpl", {
      role_arn         = aws_iam_role.loki_irsa_role.arn
      region           = var.region
      chunks_bucket    = aws_s3_bucket.loki_chunks.bucket
    })
  ]
}

resource "aws_s3_bucket" "loki_chunks" {
  bucket = "${var.project_name}-loki-${random_id.suffix.hex}"
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
    - url: http://loki.loki.svc.cluster.local:3100/loki/api/v1/push
EOF
  ]
}