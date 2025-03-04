resource "helm_release" "prometheus_stack" {
  name       = "prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.helm_version
  namespace  = "monitoring"

  create_namespace = true

  values = [
    templatefile("${path.module}/prometheus-values.yaml.tpl", {
      grafana_password    = var.grafana_password
      grafana_host        = var.grafana_host
      grafana_db_host     = var.grafana_db_host
      grafana_db_user     = var.grafana_db_user
      grafana_db_name     = var.grafana_db_name
      grafana_db_password = var.grafana_db_password
      grafana_email       = var.grafana_email
      email_server        = var.email_server
      email_port          = var.email_port
    })
  ]

  depends_on = [kubectl_manifest.email_secret]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubectl_manifest" "email_secret" {
  yaml_body = <<-EOT
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: email
  namespace: monitoring
spec:
  secretStoreRef:
    name: aws-parameter-store
    kind: ClusterSecretStore
  target:
    name: email
    namespace: monitoring
  data:
  - secretKey: email_user
    remoteRef:
      key: /${var.project_name}/email_user
  - secretKey: email_password
    remoteRef:
      key: /${var.project_name}/email_password
EOT

  depends_on = [kubernetes_namespace.monitoring]
}



