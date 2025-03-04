resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.helm_argocd_version
  namespace  = "argocd"
  create_namespace = true

  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }
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
              name: http
EOF
depends_on = [ helm_release.argocd ]
}

