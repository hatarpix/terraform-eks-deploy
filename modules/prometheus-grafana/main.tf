resource "helm_release" "prometheus_stack_db" {
  count      = var.create_db ? 1 : 0
  name       = "prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "62.4.0"
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

  depends_on = [postgresql_database.grafana_db, kubectl_manifest.email_secret, kubectl_manifest.ssl_cert_secret]
}

# without create DB
resource "helm_release" "prometheus_stack_without_db" {
  count      = var.create_db ? 0 : 1
  name       = "prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "62.4.0"
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

  depends_on = [kubectl_manifest.email_secret, kubectl_manifest.ssl_cert_secret]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubectl_manifest" "email_secret" {
  yaml_body = <<-EOT
apiVersion: external-secrets.io/v1alpha1
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
      key: /global/email_user
  - secretKey: email_password
    remoteRef:
      key: /global/email_password
EOT

  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubectl_manifest" "ssl_cert_secret" {
  yaml_body = <<-EOT
apiVersion: external-secrets.io/v1alpha1
kind: ExternalSecret
metadata:
  name: ssl-cert
  namespace: monitoring
spec:
  secretStoreRef:
    name: aws-parameter-store
    kind: ClusterSecretStore
  target:
    name: ssl-cert
    namespace: monitoring
    type: kubernetes.io/tls
  data:
  - secretKey: tls.crt
    remoteRef:
      key: /global/ssl_cert
  - secretKey: tls.key
    remoteRef:
      key: /global/ssl_key
EOT

  depends_on = [kubernetes_namespace.monitoring]
}

