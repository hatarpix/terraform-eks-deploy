resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.5.2"
  namespace  = "argocd"
  create_namespace = true
}

resource "kubectl_manifest" "argocd_cm" {
  yaml_body = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-cm
    app.kubernetes.io/part-of: argocd
data:
    ${join("\n    ", [for entry in var.argocd_accounts_entries : "accounts.${entry.user}: \"${entry.permissions}\""])}
EOF
depends_on = [ helm_release.argocd ]
}

resource "kubectl_manifest" "argocd_rbac_cm" {
  yaml_body = <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: argocd
  labels:
    app.kubernetes.io/name: argocd-rbac-cm
    app.kubernetes.io/part-of: argocd
data:
  policy.default: role:''
  policy.csv: |
    p, role:org-admin, applications, *, */*, allow
    p, role:org-admin, clusters, get, *, allow
    p, role:org-admin, repositories, get, *, allow
    p, role:org-admin, repositories, create, *, allow
    p, role:org-admin, repositories, update, *, allow
    p, role:org-admin, repositories, delete, *, allow
    p, role:org-admin, logs, get, *, allow
    p, role:org-admin, exec, create, */*, allow

    ${join("\n    ", [for entry in var.argocd_rbac_entries : "g, ${entry.user}, ${entry.role}"])}
EOF
depends_on = [ helm_release.argocd ]
}

resource "kubectl_manifest" "argocd_server_ingress" {
  yaml_body = <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    external-dns.alpha.kubernetes.io/hostname: ${var.argocd_host}
spec:
  ingressClassName: nginx
  rules:
  - host: ${var.argocd_host}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              name: https
  tls:
  - hosts:
    - ${var.argocd_host}
    secretName: ssl-cert
EOF
depends_on = [ helm_release.argocd ]
}

resource "kubectl_manifest" "ssl_cert_secret" {
  yaml_body = <<-EOT
apiVersion: external-secrets.io/v1alpha1
kind: ExternalSecret
metadata:
  name: ssl-cert
  namespace: argocd
spec:
  secretStoreRef:
    name: aws-parameter-store
    kind: ClusterSecretStore
  target:
    name: ssl-cert
    namespace: argocd
    type: kubernetes.io/tls
  data:
  - secretKey: tls.crt
    remoteRef:
      key: /global/ssl_cert
  - secretKey: tls.key
    remoteRef:
      key: /global/ssl_key
EOT

  depends_on = [helm_release.argocd]
}
