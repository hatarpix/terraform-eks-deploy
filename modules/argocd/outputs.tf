output "argocd_url" {
  value = "https://${var.argocd_host}"
}




#Retrieve the ArgoCD Admin Password:

data "kubernetes_secret" "argocd_initial_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }

  depends_on = [helm_release.argocd]
}

output "argocd_admin_password" {
  value     = data.kubernetes_secret.argocd_initial_password.data.password
  sensitive = true
}
